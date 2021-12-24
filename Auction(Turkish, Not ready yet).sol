// SPDX-License-Identifier: Unlicansed
pragma solidity ^0.8.7;

contract MyTheme {

    // Kontratın sahibi, "payable" ve "public" in yazılış sırası önemli neden bilmiyorum şimdilik.
    address payable public owner;   // Bunu tanımlarken "payable" ekleyince constructor'da sorun çıkıyor. "payable" yi constructor'a ekleyince sorun olmuyor.

    // Kontrata 3 adet durum belirledik, enum kullanıma hakim değilim kullanmak gerekmiyor olabilir.
    enum Situation {Active, Deactive, Unkown}
    Situation public contractSituation;

    constructor() {
        owner = payable(msg.sender);
        contractSituation = Situation.Active;
    }

    // Olmazsa olmazlar, kontratın transfer kabul edebilmesi için gereken fonksiyonlar
    receive() external payable{
    }
    fallback() external payable{
    }

    // Sadece "owner" address'in yapabileceği şeyleri belirlemek için modifer tanımladık.
    modifier onlyOwner {
        require(owner == msg.sender);   // "==" iki eşittire dikkat et, tek eşittir yaptım diye 2 saat sıkıntı ne diye aradım.
        _;
    }

    // "owner" ın çağıramayacağı fonksiyonları belirlemek için modifier tanımladık.
    modifier notOwner() {
        require(owner != msg.sender);
        _;
    }

    // Kontratın bakiyesini gösteren fonksiyon.
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // Buradan emin değilim?
    // Kontrattan birine Eth yollamak için gereken fonksiyon.
    // Sadece owner kullanabilmeli bu fonksiyonu.
    function sendEther(address payable _recipient, uint _amount) public onlyOwner returns(bool) {
        require(owner == msg.sender, "Transfer failed, you are not the owner!");

        // Eğer yollanacak miktar balance'den küçükse işlem gerçekleştirilir değilse iptal edilir.
        if (_amount <= getBalance()) {
            _recipient.transfer(_amount);
            return true;
        } else {
            return false;
        }
    }
}
