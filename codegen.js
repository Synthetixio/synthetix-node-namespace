#!/usr/bin/env node

const fs = require('node:fs').promises;
const ethers = require('ethers');

async function codegen({ chainId, contractName, contractAddress }) {
  const Contract = {
    address: contractAddress,
  };

  console.log(`Reading build from './out/${contractName}.sol/${contractName}.json'`);
  Contract.build = JSON.parse(
    await fs.readFile(`./out/${contractName}.sol/${contractName}.json`, 'utf8')
  );

  console.log(
    `Reading broadcast for ${contractName} ${chainId} from './broadcast/deploy.s.sol/${chainId}/run-latest.json'`
  );
  Contract.broadcast = JSON.parse(
    await fs.readFile(`./broadcast/deploy.s.sol/${chainId}/run-latest.json`, 'utf8')
  );

  console.log(`Copying 'deployments_${chainId}.json' to 'deployments/${chainId}/deployments.json'`);
  await fs.copyFile(`./deployments_${chainId}.json`, `deployments/${chainId}/deployments.json`);

  console.log(`Writing 'deployments/${chainId}/${contractName}.json'`);
  await fs.writeFile(
    `deployments/${chainId}/${contractName}.json`,
    JSON.stringify(Contract.build.abi, null, 2),
    'utf8'
  );

  console.log(`Writing 'deployments/${chainId}/${contractName}.meta.json'`);
  await fs.writeFile(
    `deployments/${chainId}/${contractName}.meta.json`,
    JSON.stringify(
      {
        blockNumber: Number.parseInt(Contract.broadcast.receipts[0].blockNumber, 16),
        transactionHash: Contract.broadcast.transactions[0].hash,
        deployer: Contract.broadcast.transactions[0].transaction.from,
      },
      null,
      2
    ),
    'utf8'
  );

  console.log(`Writing 'deployments/${chainId}/${contractName}.js'`);
  await fs.writeFile(
    `deployments/${chainId}/${contractName}.js`,
    [
      `exports.address = "${Contract.address}";`,
      `exports.abi = ${JSON.stringify(new ethers.Interface(Contract.build.abi).format(), null, 2)};`,
    ].join('\n'),
    'utf8'
  );
}

async function main() {
  const files = await fs.readdir('./', { withFileTypes: true });
  const deploymentsFiles = files.filter(
    (file) => file.isFile() && file.name.startsWith('deployments_') && file.name.endsWith('.json')
  );
  if (deploymentsFiles.length === 0) {
    throw new Error('No deployments found');
  }
  for (const file of deploymentsFiles) {
    const deployments = JSON.parse(await fs.readFile(`./${file.name}`, 'utf8'));
    const chainId = file.name.split('_')[1].split('.')[0];
    console.log(`Cleaning './deployments/${chainId}'`);
    await fs.rm(`./deployments/${chainId}`, { force: true, recursive: true });
    await fs.mkdir(`./deployments/${chainId}`, { recursive: true });

    console.log(`Processing deployments for chainId ${chainId}`);
    for (const [contractName, contractAddress] of Object.entries(deployments)) {
      console.log(`Processing ${contractName}: ${contractAddress}`);
      await codegen({ chainId, contractName, contractAddress });
    }
  }
}

main();
