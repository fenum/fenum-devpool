
## Деплой
Для создания новой сид фразы при деплое из терминала:
```bash
yarn run mnemonic
```


### Деплой Remix
  - Переключить MetaMask в нужную сеть;
  - Пополнить баланс;
  - Открыть сайт [http://remix.ethereum.org/](http://remix.ethereum.org/);
  - Создать в Remix файл `FenumDevPool.sol` и скопировать в него содержимое файла `contracts/FenumDevPool.sol`;
  - Компиляция:
    - `COMPILER`: `0.7.6`;
    - `Enable optimization`: `true`;
    - `runs`: с `200` на `999999`;
    - Нажать кнопку `Compile FenumDevPool.sol`.
  - Деплой:
    - `ENVIRONMENT`: `Injected Web3` (появится адрес и баланс из `MetaMask`);
    - `CONTRACT`: `FenumDevPool - browser/FenumDevPool.sol`;
    - Указать параметры:
      - Массив из адресов ["0x","0x"] тех кто имеет право подписывать транзакции;
      - Пороговое число подписей после которого можно отправить транзакцию, не больше количества подписантов;
      - Адрес `FenumVesting` (VESTING_ADDRESS).
    - Нажать кнопку `Deploy`.
  - Верификация контракта на `Etherscan`:
    - Открыть контракт во вкладке `Contract`;
    - Нажать `Verify and Publish`;
    - `Please select Compiler Type`: `Solidity (Single file)`;
    - `Please select Compiler Version`: `v0.7.6`;
    - `Please select Open Source License Type`: `MIT License (MIT)`;
    - `Continue`;
    - `Optimization`: `Yes`;
    - Вставить код контракта `FenumDevPool.sol` в поле `Enter the Solidity Contract Code below *`;
    - Открыть `(Runs, EvmVersion & License Type settings)`;
    - `Runs`: `999999`;
    - Нажать `Verify and Publish`.
  - Добавление получателей в вестинг:
    - В контракте `FenumToken` cделать `approve` на адрес `FenumDevPool` (в MetaMask или Etherscan) в точном количестве FNM которые предназанчены для получателя (!децимал помним);
    - В контракте `FenumDevPool` cделать `createVestingSchedule` (в MetaMask или Etherscan): адрес получателя и количество FNM (!децимал помним);



### Деплой Development
В отдельном терминале запустить `ganache-cli`:
```bash
yarn run ganache-cli
```

После этого деплой:
```bash
yarn run deploy development
```


### Деплой Mainnet
```bash
yarn run deploy mainnet
yarn run verify mainnet FenumDevPool
```


### Деплой Ropsten
```bash
yarn run deploy ropsten
yarn run verify ropsten FenumDevPool
```


### Деплой Kovan
```bash
yarn run deploy kovan
yarn run verify kovan FenumDevPool
```


### Деплой Rinkeby
```bash
yarn run deploy rinkeby
yarn run verify rinkeby FenumDevPool
```


### Деплой Goerli
```bash
yarn run deploy goerli
yarn run verify goerli FenumDevPool
```


### Публикация в NPM
После деплоя нужно опубликовать в [NPM](https://www.npmjs.com/).
```bash
npm publish
# или
yarn publish
```
