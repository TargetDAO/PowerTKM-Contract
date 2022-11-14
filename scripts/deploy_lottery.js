//hardhat库使用ethers组件与区块链进行交互
const { ethers } = require("hardhat");

//部署主函数
async function main() {
    const NewLottery = await ethers.getContractFactory("NewLottery");
    const lottery = await NewLottery.deploy()
    console.log(lottery.address)
}

//执行部署
main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});