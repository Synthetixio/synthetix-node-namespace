#!/usr/bin/env node


const fs = require('node:fs').promises;
const ethers = require('ethers');

async function codegen(chainId) {
  try {
    console.log(`Cleaning './deployments/${chainId}'`);
    await fs.rm(`./deployments/${chainId}`, {force: true, recursive: true});
    await fs.mkdir(`./deployments/${chainId}`, {recursive: true});

    const Namespace = {};

    console.log(`Reading build from './out/Namespace.sol/Namespace.json'`);
    Namespace.build = JSON.parse(await fs.readFile('./out/Namespace.sol/Namespace.json', 'utf8'));

    console.log(
      `Reading broadcast for Namespace ${chainId} from './broadcast/NamespaceDeployment.s.sol/${chainId}/run-latest.json'`
    );
    Namespace.broadcast = JSON.parse(
      await fs.readFile(`./broadcast/NamespaceDeployment.s.sol/${chainId}/run-latest.json`, 'utf8')
    );

    console.log(`Reading deployments for Namespace from './deployments_${chainId}.json'`);
    Namespace.address = JSON.parse(await fs.readFile(`./deployments_${chainId}.json`, 'utf8')).Namespace;

    console.log(`Copying 'deployments_${chainId}.json' to 'deployments/${chainId}/deployments.json'`);
    await fs.copyFile(`./deployments_${chainId}.json`, `deployments/${chainId}/deployments.json`);

    console.log(`Writing 'deployments/${chainId}/Namespace.json'`);
    await fs.writeFile(`deployments/${chainId}/Namespace.json`, JSON.stringify(Namespace.build.abi, null, 2), 'utf8');

    console.log(`Writing 'deployments/${chainId}/Namespace.meta.json'`);
    await fs.writeFile(
      `deployments/${chainId}/Namespace.meta.json`,
      JSON.stringify(
        {
          blockNumber: Number.parseInt(Namespace.broadcast.receipts[0].blockNumber, 16),
          transactionHash: Namespace.broadcast.transactions[0].hash,
          deployer: Namespace.broadcast.transactions[0].transaction.from,
        },
        null,
        2
      ),
      'utf8'
    );

    console.log(`Writing 'deployments/${chainId}/Namespace.js'`);
    await fs.writeFile(
      `deployments/${chainId}/Namespace.js`,
      [
        `exports.address = "${Namespace.address}";`,
        `exports.abi = ${JSON.stringify(new ethers.Interface(Namespace.build.abi).format(), null, 2)};`,
      ].join('\n'),
      'utf8'
    );
  } catch (error) {
    console.error(`Error processing chainId ${chainId}:`, error.message || error);
  }
}

async function main() {
  try {
    const namespaceDirectories = await fs.readdir('./broadcast/NamespaceDeployment.s.sol/', {withFileTypes: true});
    if (namespaceDirectories.length === 0) {
      throw new Error(`No chainId folders found in NamespaceDeployment.s.sol.`);
    }
    for (const dir of namespaceDirectories) {
      if (dir.isDirectory()) {
        const chainId = dir.name;
        console.log(`Processing NamespaceDeployment for chainId ${chainId}`);
        await codegen(chainId);
      }
    }

  } catch (error) {
    console.error(`Unhandled error in main function:`, error.message || error);
  }
}

main();
