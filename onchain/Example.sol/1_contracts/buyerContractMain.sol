// buyer order --> Seller Accept  --> Deliverymamn Accept   -->   Buyer Pay   -->   Contract Deploy

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ecmart {
   private deliverycharge = [[will be set dynamically from code]]
   private sellerAddress = [[will be set dynamically from code]]  
   private deliverymanAddress = [[will be set dynamically from code]]  
   private meanRollBackDuration = [[will be set dynamically from code]]  
   private isPaid = false;

   public pay (){
      if(owner == _msg.sender){
         sellerAddress.transfer((address)this.balance - deliverycharge);
         deliverymanAddress.transfer(deliverycharge);
         isPaid = true;
      }
   }

   public rollback(){
      if(owner == _msg.sender && (this.creationTime - currentTime ) >= meanRollBackDuration && !isPaid){
         owner.transfer((address)this.balance);
      }
   }

}
