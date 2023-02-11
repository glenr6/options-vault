# Option Valut

Sell call options.

First, download this branch:
```shell
git clone -b combined_token_contract https://github.com/glenr6/options-vault.git
```

When inside the `options-vault` folder that just got created, run
```shell
yarn install
```
to install the necessary packages. Start a local blockchain where we will later deploy the contract:
```shell
yarn hardhat node
```
Now spawn another terminal and compile & deploy the contract:
```shell
yarn hardhat run scripts/deploy.ts
```
If you want to compile the contracts but not deploy them, run
```shell
yarn hardhat compile
```