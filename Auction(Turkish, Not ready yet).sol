// SPDX-License-Identifier: Unlicansed
pragma solidity ^0.8.7;

contract Auction {

    address payable public owner;

    // Auction'un başlama ve bitiş zamanlarını hesaplamamızda kullanılacak değişkenler.
    uint public startBlock;
    uint public endBlock;

    // Auction'un bilgileri, resimler vb. şeyleri blockchain'e kaydetmek pahalı olduğu için bu bilgileri kaydetmek için off chain bir çözüm kullanıyoruz.
    string public ipfsHash;

    enum State {Started, Running, Ended, Canceled}  // Olabilecek durumları tanımladık.
    State public auctionState;  // Şu anki durumun nasıl olduğunu belirtebilmek için sonra kullanmak üzere bir değişken tanımladık fakat ona variable eklemedik daha.

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;
    uint bindIncrement;

    constructor() {
        owner = payable(msg.sender);
        auctionState = State.Started;
        startBlock = block.number; // "block.number" şu anki bloğun numarasını alıyor bu da ilk blok olmuş oluyor.
        endBlock = startBlock + 40320; // Her bir blok için ortalama 15 saniye geçiyormuş böylelikle bitiş tarihi hesaplandı
        ipfsHash = "";  // "I'm initializing it to an empty string" ???
        bindIncrement = 100; // Bid arttırmak için 100 wei ödenmesi gerekiyor.
    }
    
    // "owner" ın yapamayacağı şeyleri belirlemek için tanımladık.
    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    // Fonksiyonun çalışabilmesi için "startBlock" ve "endBlock" arasında olması gerektiğini tanımladık
    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }
    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    // Solidity'de iki sayıdan küçük olanı bulmak için bir fonskiyon yok o yüzden biz kendimize tanımlıyoruz.
    function min(uint a, uint b) pure internal returns(uint) {
        if(a <= b) {
            return a;
        } else {
            return b;
        }
    }

    // İlk komplike kodlarımdan biri olduğu için kafam biraz karışık ve bazı yerleri yanlış açıklamış olabilirim.
    // Bu fonksiyon bizim ana fonksiyonumuz. Bid yapma işlemlerini halledicek.
    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running); // Başlayabilmesi için önceden tanımladığımız enum'u çağırdık.
        require(msg.value >= 100);  // Minimum bid'i 100 wei olarak ayarladık

        uint currentBid = bids[msg.sender] + msg.value; // Kullanıcının şu anki bid'ini görebilmesi için önceden tanımladığımız mapping'i çağırıp, önceki bid'ine şu an yaptığı bid'i ekleyen bir local variable tanımladık.
        require(currentBid > highestBindingBid); // En son bid'i en yüksek bid'den yüksek olması gerektiğini tanımladık.

        bids[msg.sender] = currentBid;  // mapping'i çağırarak şu anki bid'le fonksiyonu kullanan kişiyi birlieştirdik?

        // currentBid en yüksek bid'den yüksek olması gerekiyor.
        if(currentBid <= bids[highestBidder]) {
            highestBindingBid = min(currentBid + bindIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bindIncrement);
            highestBidder = payable(msg.sender);
        }


    }
}
