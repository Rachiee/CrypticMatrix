# Cryptic Matrix

**Cryptic Matrix** is a blockchain-based scavenger hunt game built on the Stacks blockchain. Participants can engage in a series of progressive puzzles and challenges to earn rewards. This contract allows for a fun and interactive experience, combining elements of gaming with the innovative capabilities of blockchain technology.

## Features

- **Progressive Puzzles**: Players advance through multiple stages, each presenting unique clues and encrypted solutions.
- **Prize Pool**: A total prize pool accumulates from entry fees, rewarding successful participants.
- **Player Tracking**: Each player’s progress is tracked, including solved stages and attempts.
- **Secure and Transparent**: Built on the Stacks blockchain, ensuring that all transactions and game logic are secure and publicly verifiable.

## Contract Structure

### Constants

- **ERR-NOT-AUTHORIZED**: Error for unauthorized access attempts.
- **ERR-HUNT-NOT-ACTIVE**: Error when the scavenger hunt is not currently active.
- **ERR-INVALID-STAGE**: Error for an invalid stage ID.
- **ERR-ALREADY-SOLVED**: Error if a stage has already been solved.
- **ERR-WRONG-SOLUTION**: Error for incorrect solutions.
- **ERR-TIME-LOCKED**: Error if the stage is not yet unlocked.
- **ERR-INSUFFICIENT-PAYMENT**: Error for insufficient entry fees.

### Data Variables

- **admin**: The principal address of the contract administrator.
- **hunt-active**: A boolean indicating if the scavenger hunt is currently active.
- **current-stage**: The ID of the current stage in the hunt.
- **entry-fee**: The entry fee required to participate in the hunt.
- **total-prize-pool**: The total accumulated prize pool.

### Hunt Stages

Each stage in the hunt is stored in a map with the following attributes:

- **clue**: The clue provided for the stage.
- **encrypted-solution**: The hashed solution for the stage.
- **unlock-height**: The block height at which the stage becomes accessible.
- **prize**: The reward for solving the stage.
- **solved**: A boolean indicating whether the stage has been solved.

### Player Progress Tracking

Player progress is tracked using a map that records:

- **current-stage**: The stage the player is currently attempting.
- **solved-stages**: A list of stages the player has successfully solved.
- **last-attempt**: The block height of the player’s last attempt.
- **total-solved**: The total number of stages the player has solved.

### Functions

- **initialize-hunt**: Starts the scavenger hunt.
- **add-stage**: Adds a new stage with a clue and solution.
- **register-player**: Registers a player for the scavenger hunt.
- **submit-solution**: Allows players to submit solutions for stages.
- **get-current-clue**: Retrieves the clue for the current stage.
- **get-player-status**: Checks the status of a specific player.
- **get-stage-winners**: Lists the winners for a given stage.
- **get-hunt-stats**: Retrieves statistics about the hunt.

### Example Usage

1. **Initialize the Hunt**:
   - The admin can start the hunt using the `initialize-hunt` function.
   
2. **Add Stages**:
   - Use `add-stage` to create new stages with clues and solutions.
   
3. **Register Players**:
   - Players register using `register-player`, paying the entry fee.
   
4. **Submit Solutions**:
   - Players can submit their solutions via `submit-solution`.
   
5. **View Clues and Status**:
   - Use `get-current-clue` and `get-player-status` to check progress.

## Deployment

To deploy the **Cryptic Matrix** smart contract, follow the instructions for deploying Clarity contracts on the Stacks blockchain. Ensure that you have the necessary development environment set up.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to enhance the functionality and user experience of the **Cryptic Matrix**.

## License

This project is licensed under the MIT License.