// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract X {
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }
    struct Message{
        uint id;
        string content;
        address from;
        address to;
        uint createdAt;
    }
    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetsOf;
    mapping(address=>Message[]) public convo;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public following;

    uint nextId;
    uint nextMessageId;

    function _tweet(address _from,string memory content) public{
        tweets[nextId]=Tweet(nextId,_from,content,block.timestamp);
        nextId++;
    }

    function _sendingMessage(address _from,address _to, string memory content) public{
        convo[_from].push(Message(nextMessageId,content,_from,_to,block.timestamp));
        nextMessageId++;
    }

    function tweet(string memory content) public{
        _tweet(msg.sender,content);
    }

    function tweet(address _from,string memory content) public{
        _tweet(_from,content);
    }

    function sendingMessage(address _to,string memory content) public{
        _sendingMessage(msg.sender,_to,content);
    }

    function sendingMessage(address _from,address _to,string memory content) public{
        _sendingMessage(_from,_to,content);
    }

    function follow(address toFollow) public{
        following[msg.sender].push(toFollow);
    }

    function accessAllowed(address _operator) public{
        operators[msg.sender][_operator]=true;
    }

    function accessDisallowed(address _operator) public{
        operators[msg.sender][_operator]=false;
    }

    function latestTweets(uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Unable to fetch latest tweets");
        Tweet[] memory _tweets= new Tweet[](count);
        uint j=0;
        for(uint i=nextId-count;i<nextId;i++){
            _tweets[j++]=Tweet(tweets[i].id,tweets[i].author,tweets[i].content,tweets[i].createdAt);
        }
        return _tweets;
    }

    function latestTweetsUser(address _user,uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Unable to fetch data");
        Tweet[] memory _tweets= new Tweet[](count);
        uint[] memory ids= tweetsOf[_user];
        require(count>0 && count<=ids.length,"Unable to fetch data");
        uint j=0;
        for(uint i=tweetsOf[_user].length-count;i<tweetsOf[_user].length;i++){
            _tweets[j++]=Tweet(tweets[ids[i]].id,tweets[i].author,tweets[i].content,tweets[i].createdAt);
        }
        return _tweets;
    }
}
