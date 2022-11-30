//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

contract RandomNum {
    address manager;
    constructor(){
        manager = msg.sender;
    }
    modifier onlyManager{
        require(msg.sender == manager);
        _;
    }
    event getOne(uint256 num);
    mapping(string=>mapping(uint256=>uint256[])) dapp_random_num;
    function setRandom(string memory token,uint256 num_type,uint256[] memory list_num)public  onlyManager {
        dapp_random_num[token][num_type]=list_num;

    }

    function addRandom(string memory token,uint256 num_type,uint256[] memory list_num)public  onlyManager {
        for(uint256 i=0;i<list_num.length;i++){
            dapp_random_num[token][num_type].push(list_num[i]);
        }
    }
    function getRandomNum(string memory token,uint256 num_type) view public returns (uint256[] memory){
        return dapp_random_num[token][num_type];
    }

    function getNumLength(string memory token,uint256 num_type) view public returns (uint256){
        return dapp_random_num[token][num_type].length;
    }

    function getOneRandomNum(string memory token,uint256 num_type)view public returns(uint256){
        uint256[]memory nums=dapp_random_num[token][num_type];
        uint256 result=nums[nums.length-1];
        return result;
    }
    function removeLast(string memory token,uint256 num_type)public{
        dapp_random_num[token][num_type].pop();
    }
}


contract NewLuck {
    event PlayResult(
        address user,
        uint256 number,
        bool is_win,
        uint256 prize
    );

    struct Ticket {
        uint256 id;
        uint256 time;
        address user;
        uint256 number;
        bool is_win;
        uint256 prize_level;
        uint256 bonus;
    }
    struct RecommProfit {
        uint256 id;
        uint256 time;
        address user;
        address recomm_user;
        uint256 number;
        bool is_win;
        uint256 bonus;
        uint256 profit;
    }
    struct WithdrawLog {
        uint256 id;
        uint256 time;
        address user;
        uint256 amount;
        uint256 status;
    }
    struct Donations{
        uint256 id;
        address user;
        uint256 add_time;
        uint256 amount;
    }
    struct DonationUserOrder{
        uint256 id;
        address user;
        address donation_user;
        uint256 add_time;
        uint256 amount;
        uint256 userProportion;
    }
    uint256 donation_start_time=1669294800;
    uint256 donation_end_time=1669824000;//
    address tech_wallet=0xF0aDf6B8cE0e771883027Fc48a15c41263d4FB3c;
    address random_addr=0x4aE5D5BA5fC4323f5c7233992f5FE05967294B6D;
    // address random_addr=0x3398986F2dF0D0B683DED915B3A7f6135aB050f0;
    string random_token="dapp_001_00001";
    RandomNum myRandomNum;
    address manager;
    uint256 total_bonus = 0*(10**18);
    uint256 total_donations=0*(10**18);
    mapping(address => uint256) user_balances;
    mapping (uint8=>mapping(uint256=>bool)) list_nums_is_win;
    mapping(uint8=>uint256[]) prize_num_list;

    mapping(uint256=>Ticket) ticket_list;
    uint256 public ticket_count=0;
    mapping(address=>mapping(uint256=>uint256)) user_tickets;
    mapping(address=>uint256) user_tickets_count;
    uint256 public big_prize_count=0;
    mapping(uint256=>uint256) list_big_prize;

    uint256 public total_donations_order_count;
    mapping(uint256=>DonationUserOrder) list_all_donation_order;
    mapping(address=>mapping(uint256=>uint256)) list_user_donation_order;
    mapping(address=>uint256) user_donation_order_count;

    bool can_donation=true;
    Donations[] donation_list;
    uint256 donations_num=0;
    mapping(address=>uint256) user_donation_num;
    mapping(address=>uint256) user_proportion;
    address[] donation_users;


    mapping(address=>address) user_recomm;
    mapping(address=>address[]) user_list_recomm;
    mapping(address=>bool) user_has_buy;
    address[] players;
    RecommProfit[] list_recomm_profit;

    mapping(uint256=>RecommProfit) recomm_profit_all_list;
    uint256 recomm_profit_all_count=0;
    mapping(address=>mapping(uint256=>uint256)) recomm_profit_user_list;
    mapping(address=>uint256) recomm_profit_user_count;



    constructor(){
        manager = msg.sender;
    }
    function play(address recomm) payable public {
        require(msg.sender == tx.origin,"not user!");
        require(msg.value == 10 ether, "please pay 10 tkm");
        require(block.timestamp>donation_end_time,"game start soon");
        myRandomNum=RandomNum(random_addr);
        uint256 _lotNumber = myRandomNum.getOneRandomNum(random_token,111);
        _lotNumber=uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,_lotNumber,total_bonus))) % 1000000;
        myRandomNum.removeLast(random_token,111);
        if(recomm!=address(0)&&recomm!=msg.sender){
            if(user_recomm[msg.sender]==address(0)){
                user_recomm[msg.sender] = recomm;
                user_list_recomm[recomm].push(msg.sender);
            }
        }
        if(!user_has_buy[msg.sender]){
            players.push(msg.sender);
            user_has_buy[msg.sender]=true;
        }

        uint256 user_prize = 0;
        uint256 prize_level=0;
        uint256 last_prize = 8*(10**18);
        bool is_big_bonus = false;
        if(list_nums_is_win[0][(_lotNumber % (10 ** 6))]){
            user_prize = total_bonus * 405 / 1000 ;
            payable(address(1)).transfer(total_bonus* 45/1000);
            prize_level=6;
            is_big_bonus = true;
        }else if(list_nums_is_win[1][(_lotNumber % (10 ** 5))]){
            user_prize = total_bonus * 225 / 10000;
            payable(address(1)).transfer(total_bonus* 25/10000);
            prize_level=5;
            is_big_bonus = true;
        }else if(list_nums_is_win[2][(_lotNumber % (10 ** 4))]){
            user_prize = 3000*(10**18);
            prize_level=4;
            is_big_bonus = true;
        }else if(list_nums_is_win[3][(_lotNumber % (10 ** 3))]){
            user_prize = 200*(10**18);
            prize_level=3;
            is_big_bonus = true;
        }else if(list_nums_is_win[4][(_lotNumber % (10 ** 2))]){
            user_prize = 30*(10**18);
            prize_level=2;
            is_big_bonus = false;
        }
        else if ((_lotNumber % 10) == 0||(_lotNumber % 10) == 1) {
            user_prize = 5*(10**18);
            prize_level=1;
            is_big_bonus = false;
        }


        payable(tech_wallet).transfer(1* 10 ** 18);
        payable(manager).transfer(1* 10 ** 17);

        last_prize=last_prize-(1* 10 ** 17);
        for(uint256 i=0;i<donation_users.length;i++){
            uint256 userProportion=user_proportion[donation_users[i]];
            uint256 userPriAmount=1*10**18*userProportion/10000;
            addDonationOrder(msg.sender,donation_users[i],userPriAmount,userProportion);
            payable(donation_users[i]).transfer(userPriAmount);
        }

        if(user_recomm[msg.sender]!=address(0)){
            last_prize = last_prize-1*10**18;
            user_balances[user_recomm[msg.sender]] = user_balances[user_recomm[msg.sender]] + 1*(10**18);
            recomm_profit_all_list[recomm_profit_all_count]=RecommProfit(list_recomm_profit.length+1,block.timestamp, msg.sender, user_recomm[msg.sender],_lotNumber, user_prize > 0, user_prize,1);
            recomm_profit_user_list[user_recomm[msg.sender]][recomm_profit_user_count[user_recomm[msg.sender]]]=recomm_profit_all_count;
            recomm_profit_all_count+=1;
            recomm_profit_user_count[user_recomm[msg.sender]]+=1;
        }

        if (user_prize > 0) {
            user_balances[msg.sender] = user_balances[msg.sender] + user_prize;
        }
        if (user_prize > last_prize) {
            total_bonus = total_bonus - (user_prize - last_prize);
        } else {
            total_bonus = total_bonus + (last_prize - user_prize);
        }
        addTicket(msg.sender, _lotNumber, user_prize > 0,prize_level, user_prize);
        if(is_big_bonus){
            addBigPrize(ticket_count);
        }
        emit PlayResult(msg.sender, _lotNumber, user_prize > 0, user_prize);
    }


    function clear_all_num()private onlyManager{
        for(uint8 i=0;i<5;i++){
            while (prize_num_list[i].length > 0) {
                delete list_nums_is_win[i][prize_num_list[i][prize_num_list[i].length - 1]];
                prize_num_list[i].pop();
            }
        }

    }
    function reset_all_num()onlyManager public{
        myRandomNum=RandomNum(random_addr);
        clear_all_num();
        for(uint8 i=0;i<5;i++){
            uint256[] memory list_num=myRandomNum.getRandomNum(random_token,i+1);
            for (uint256 j = 0; j < list_num.length; j++) {
                prize_num_list[i].push(list_num[j]);
                list_nums_is_win[i][list_num[j]]=true;
            }
        }
    }

    function checkWithdraw(uint256 id,address user,uint256 time,uint256 amount)public  onlyManager {
        if(withdraw_all_list[id].status==0&&withdraw_all_list[id].user==user&&withdraw_all_list[id].time==time&&withdraw_all_list[id].amount==amount){
            withdraw_all_list[id].status=1;
            payable(withdraw_all_list[id].user).transfer(withdraw_all_list[id].amount*10**18);
        }
    }
    modifier onlyManager{
        require(msg.sender == manager);
        _;
    }

    function make_donations() payable public{
        uint256 per_num=10000;
        require(msg.sender == tx.origin,"not user!");
        require(can_donation,"Has stopped accepting fundraising");
        require(block.timestamp>donation_start_time,"The fundraising has not started yet");
        require(block.timestamp<donation_end_time,"The fundraising has ended");
        require((msg.value%(per_num*10**18)==0),"The fundraising amount must be a multiple of 10000");
        require(donations_num <= 500,"The maximum number of fundraising is 100");

        uint256 number=msg.value;
        uint256 num=number/(per_num*10**18);
        require((num+user_donation_num[msg.sender])<=5,"The max donation times mush less than 5");
        total_donations=total_donations+number;
        total_bonus=total_bonus+number;
        donations_num=num+donations_num;
        donation_list.push(Donations(donation_list.length+1,msg.sender,block.timestamp,msg.value));
        if(user_donation_num[msg.sender]>0){
            user_donation_num[msg.sender]=user_donation_num[msg.sender]+num;
        }else{
            user_donation_num[msg.sender]=num;
            donation_users.push(msg.sender);
        }
        if(donation_users.length>=100){
            donation_end_time-block.timestamp;
            can_donation=false;
        }
        for (uint256 i = 0; i < donation_users.length; i++) {
            user_proportion[donation_users[i]]=user_donation_num[donation_users[i]]*10000/donations_num;
        }
    }
    function getUserDonations() view public returns (Donations[] memory){
        uint256 max_list_size = donation_list.length;
        uint256 total_num = 0;
        for (uint256 i = 0; i < max_list_size; i++) {
            if (donation_list[i].user == msg.sender) {
                total_num++;
            }
        }
        uint256 currentIndex = 0;
        Donations[] memory list_result = new Donations[](total_num);
        for (uint256 i = 0; i < max_list_size; i++) {
            if (donation_list[i].user == msg.sender) {
                list_result[currentIndex] = donation_list[i];
                currentIndex++;
            }
        }
        return list_result;
    }
    function getDonationsTotal()view public returns(uint256){
        return donations_num;
    }
    function getDonationsUserTotal()view public returns(uint256){
        return donation_users.length;
    }

    function getAllDonations()view public returns(Donations[] memory){
        return donation_list;
    }
    function getUserDonationNum()view public returns(uint256){
        return user_donation_num[msg.sender];
    }
    function getUserProportion()view public returns(uint256){
        return user_proportion[msg.sender];
    }

    mapping(uint256=>WithdrawLog) withdraw_all_list;
    uint256 withdraw_all_count;
    mapping(address=>mapping(uint256=>uint256)) withdraw_user_list;
    mapping(address=>uint256) withdraw_user_count;
    bool locked = false;
    function userWithdraw(uint256 amount) public{
        require(!locked, "Reentrant call detected!");
        require(amount >= 100, "Withdrawal amount must exceed 100");
        require(amount <= user_balances[msg.sender]/(10**18), "Your balance is insufficient");
        require(amount <= address(this).balance/(10**18), "the contract balance is insufficient");
        locked = true;
        user_balances[msg.sender] = user_balances[msg.sender] - amount*(10**18);
        withdraw_all_list[withdraw_all_count]=WithdrawLog(withdraw_all_count,block.timestamp, msg.sender, amount, 0);
        withdraw_user_list[msg.sender][withdraw_user_count[msg.sender]]=withdraw_all_count;
        withdraw_all_count+=1;
        withdraw_user_count[msg.sender]+=1;
        locked = false;
    }

    function getWithdraw(uint256 id)view public returns(WithdrawLog memory){
        return withdraw_all_list[id];
    }
    function getAllWithdrawList(uint256 start,uint256 size) view public returns (WithdrawLog[] memory){
        if(size==0){
            size=withdraw_all_count;
        }
        if(start+size>withdraw_all_count){
            size=withdraw_all_count-start;
        }
        WithdrawLog[] memory list_result=new WithdrawLog[](size);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getWithdraw(i);
        }
        return list_result;
    }
    function getWithdrawList(uint256 start,uint256 size) view public returns (WithdrawLog[] memory){
        uint256 count=withdraw_user_count[msg.sender];
        if(size==0){
            size=count;
        }
        if(start+size>count){
            size=count-start;
        }
        WithdrawLog[] memory list_result=new WithdrawLog[](size);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getWithdraw(withdraw_user_list[msg.sender][i]);
        }
        return list_result;
    }

    function addTicket(address user,uint256 number,bool is_win,uint256 prize_level,uint256 bonus)private{
        Ticket memory newTicket=Ticket(ticket_count,block.timestamp,user,number,is_win,prize_level,bonus);
        ticket_list[ticket_count]=newTicket;
        user_tickets[user][user_tickets_count[user]]=ticket_count;
        ticket_count+=1;
        user_tickets_count[user]+=1;
    }
    function getTicket(uint256 id)view public returns(Ticket memory){
        return ticket_list[id];
    }
    function getUserTicketCount()view public returns(uint256){
        return user_tickets_count[msg.sender];
    }
    function addBigPrize(uint256 id)private{
        list_big_prize[big_prize_count]=id;
        big_prize_count+=1;
    }
    function getAllList(uint256 start,uint256 size) view public returns (Ticket[] memory){
        if(size==0){
            size=ticket_count;
        }
        if(start+size>ticket_count){
            size=ticket_count-start;
        }
        Ticket[] memory list_result=new Ticket[](size);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getTicket(i);
        }
        return list_result;
    }
    function getBigPrizeList() view public returns (Ticket[] memory){
        uint256 count=big_prize_count;
        if(big_prize_count>10){
            count=10;
        }
        Ticket[] memory list_result=new Ticket[](count);
        for(uint256 i=0;i<count;i++){
            list_result[i]=getTicket(list_big_prize[big_prize_count-i]);
        }
        return list_result;
    }
    function getTicketList(uint256 start,uint256 size) view public returns (Ticket[] memory){
        uint256 count=user_tickets_count[msg.sender];
        if(size==0){
            size=count;
        }
        if(start+size>count){
            size=count-start;
        }

        Ticket[] memory list_result=new Ticket[](count);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getTicket(user_tickets[msg.sender][i]);
        }
        return list_result;
    }

    function addDonationOrder(address user,address donation_user,uint256 amount,uint256 userProportion)private{
        DonationUserOrder memory newItem=DonationUserOrder(total_donations_order_count+1,user,donation_user,block.timestamp,amount,userProportion);
        list_all_donation_order[total_donations_order_count]=newItem;
        list_user_donation_order[donation_user][user_donation_order_count[donation_user]]=total_donations_order_count;
        total_donations_order_count+=1;
        user_donation_order_count[donation_user]+=1;
    }
    function getDonationOrder(uint256 id)view public returns(DonationUserOrder memory){
        return list_all_donation_order[id];
    }
    function get_user_list_donation_order() view public returns (DonationUserOrder[] memory){
        uint256 count=user_donation_order_count[msg.sender];
        DonationUserOrder[] memory list_result=new DonationUserOrder[](count);
        for(uint256 i=0;i<count;i++){
            list_result[i]=getDonationOrder(list_user_donation_order[msg.sender][i]);
        }
        return list_result;
    }
    function getAllDonationsOrder()view public returns(DonationUserOrder[] memory){
        DonationUserOrder[] memory list_result=new DonationUserOrder[](total_donations_order_count);
        for(uint256 i=0;i<total_donations_order_count;i++){
            list_result[i]=getDonationOrder(i);
        }
        return list_result;
    }

    function getAllRecommProfitList(uint256 start,uint256 size) view public returns (RecommProfit[] memory){
        if(size==0){
            size=recomm_profit_all_count;
        }
        if(start+size>recomm_profit_all_count){
            size=recomm_profit_all_count-start;
        }
        RecommProfit[] memory list_result=new RecommProfit[](size);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getRecommProfit(i);
        }
        return list_result;
    }
    function getRecommProfit(uint256 id)view public returns(RecommProfit memory){
        return recomm_profit_all_list[id];
    }
    function getRecommProfitList(uint256 start,uint256 size) view public returns (RecommProfit[] memory){
        uint256 count=recomm_profit_user_count[msg.sender];
        if(size==0){
            size=count;
        }
        if(start+size>count){
            size=recomm_profit_user_count[msg.sender]-start;
        }

        RecommProfit[] memory list_result=new RecommProfit[](count);
        for(uint256 i=start;i<start+size;i++){
            list_result[i]=getRecommProfit(recomm_profit_user_list[msg.sender][i]);
        }
        return list_result;
    }


    function getUserBalance() view public returns (uint256){
        return user_balances[msg.sender];
    }
    function getTotalBonus() view public returns (uint256){
        return total_bonus;
    }
    function getTopNumList(uint8 i) public view  returns (uint256[] memory){
        return prize_num_list[i];
    }
    function get_recomm()view public returns(address){
        return  user_recomm[msg.sender];
    }


}