;; Crypto Scavenger Hunt
;; A blockchain-based scavenger hunt with progressive puzzles and rewards

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-HUNT-NOT-ACTIVE (err u2))
(define-constant ERR-INVALID-STAGE (err u3))
(define-constant ERR-ALREADY-SOLVED (err u4))
(define-constant ERR-WRONG-SOLUTION (err u5))
(define-constant ERR-TIME-LOCKED (err u6))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u7))

;; Data Variables
(define-data-var admin principal tx-sender)
(define-data-var hunt-active bool false)
(define-data-var current-stage uint u0)
(define-data-var entry-fee uint u1000000) ;; 1 STX
(define-data-var total-prize-pool uint u0)

;; Hunt Stage Structure
(define-map hunt-stages
    uint
    {
        clue: (string-utf8 256),
        solution-hash: (buff 32), ;; SHA256 hash of the solution
        unlock-height: uint,
        prize: uint,
        solved: bool
    }
)

;; Player Progress Tracking
(define-map player-progress
    principal
    {
        current-stage: uint,
        solved-stages: (list 20 uint),
        last-attempt: uint,
        total-solved: uint
    }
)

;; Player Solutions History
(define-map stage-solutions
    {stage: uint, player: principal}
    {
        attempts: uint,
        solved-at: (optional uint)
    }
)

;; Events
(define-map stage-winners
    uint
    (list 10 {player: principal, solved-at: uint})
)

;; Authorization
(define-private (is-admin)
    (is-eq tx-sender (var-get admin)))

;; Hunt Management Functions
(define-public (initialize-hunt)
    (begin
        (asserts! (is-admin) ERR-NOT-AUTHORIZED)
        (var-set hunt-active true)
        (var-set current-stage u0)
        (var-set total-prize-pool u0)
        (ok true)))

(define-public (add-stage
    (stage-id uint)
    (clue (string-utf8 256))
    (solution-hash (buff 32))
    (unlock-height uint)
    (prize uint))
    (begin
        (asserts! (is-admin) ERR-NOT-AUTHORIZED)
        (map-set hunt-stages stage-id
            {
                clue: clue,
                solution-hash: solution-hash,
                unlock-height: unlock-height,
                prize: prize,
                solved: false
            })
        (var-set total-prize-pool (+ (var-get total-prize-pool) prize))
        (ok true)))

;; Player Registration
(define-public (register-player)
    (begin
        (asserts! (var-get hunt-active) ERR-HUNT-NOT-ACTIVE)
        ;; Require entry fee
        (try! (stx-transfer? (var-get entry-fee) tx-sender (var-get admin)))
        
        (map-set player-progress tx-sender
            {
                current-stage: u0,
                solved-stages: (list),
                last-attempt: u0,
                total-solved: u0
            })
        (ok true)))

;; Gameplay Functions
(define-public (submit-solution
    (stage-id uint)
    (solution (buff 32)))
    (let (
        (stage (unwrap! (map-get? hunt-stages stage-id) ERR-INVALID-STAGE))
        (player (unwrap! (map-get? player-progress tx-sender) ERR-INVALID-STAGE))
        )
        ;; Check stage availability
        (asserts! (var-get hunt-active) ERR-HUNT-NOT-ACTIVE)
        (asserts! (>= block-height (get unlock-height stage)) ERR-TIME-LOCKED)
        (asserts! (not (get solved stage)) ERR-ALREADY-SOLVED)
        
        ;; Verify solution - directly compare the hashes
        (if (is-eq solution (get solution-hash stage))
            (begin
                ;; Update stage status
                (map-set hunt-stages stage-id
                    (merge stage {solved: true}))
                
                ;; Update player progress
                (map-set player-progress tx-sender
                    (merge player {
                        current-stage: (+ stage-id u1),
                        solved-stages: (unwrap! (as-max-len? 
                            (append (get solved-stages player) stage-id) u20)
                            ERR-INVALID-STAGE),
                        total-solved: (+ (get total-solved player) u1)
                    }))
                
                ;; Record solution
                (map-set stage-solutions
                    {stage: stage-id, player: tx-sender}
                    {
                        attempts: u1,
                        solved-at: (some block-height)
                    })
                
                ;; Award prize
                (try! (stx-transfer? (get prize stage) (var-get admin) tx-sender))
                
                ;; Record winner
                (match (map-get? stage-winners stage-id)
                    winners (map-set stage-winners stage-id
                        (unwrap! (as-max-len?
                            (append winners {player: tx-sender, solved-at: block-height})
                            u10)
                            ERR-INVALID-STAGE))
                    (map-set stage-winners stage-id
                        (list {player: tx-sender, solved-at: block-height})))
                
                (ok true))
            ERR-WRONG-SOLUTION)))

;; Read-only functions
(define-read-only (get-current-clue (stage-id uint))
    (match (map-get? hunt-stages stage-id)
        stage (if (>= block-height (get unlock-height stage))
            (ok (get clue stage))
            ERR-TIME-LOCKED)
        ERR-INVALID-STAGE))

(define-read-only (get-player-status (player principal))
    (map-get? player-progress player))

(define-read-only (get-stage-winners (stage-id uint))
    (map-get? stage-winners stage-id))

(define-read-only (get-hunt-stats)
    {
        active: (var-get hunt-active),
        current-stage: (var-get current-stage),
        total-prize-pool: (var-get total-prize-pool),
        entry-fee: (var-get entry-fee)
    })