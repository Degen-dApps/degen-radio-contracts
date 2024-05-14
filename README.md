# Degen Radio smart contracts

Smart contracts for the Degen Radio dApp.

## Quickstart

### Install dependencies

```bash
npm i
```

### Create .env file

Copy `.env.example` and create a `.env` file. Then enter your deployer private key in it (use a key that you use only for deployments and holds only very small amount of funds).

**Important:** The `.env` file is listed in `.gitignore` and it should never be added to the git repository (even if it's private on GitHub).

### Tests

Tests are in the `test` folder. The run command is at the top of each test file.
