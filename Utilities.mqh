#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\List.mqh>


int closePositionMagic = 200;

void setClosePositionMagic(int magic){
   closePositionMagic = magic;
}

// Print MqlTradeTransaction data structure
void printTradeTransaction(const MqlTradeTransaction &trans) {
//--- 
   string desc= "MqlTradeTransaction \r\n";
   desc+="     - Type: "+EnumToString(trans.type)+"\r\n";
   desc+="     - Symbol: "+trans.symbol+"\r\n";
   desc+="     - Deal ticket: "+(string)trans.deal+"\r\n";
   desc+="     - Deal type: "+EnumToString(trans.deal_type)+"\r\n";
   desc+="     - Order ticket: "+(string)trans.order+"\r\n";
   desc+="     - Order type: "+EnumToString(trans.order_type)+"\r\n";
   desc+="     - Order state: "+EnumToString(trans.order_state)+"\r\n";
   desc+="     - Order time type: "+EnumToString(trans.time_type)+"\r\n";
   desc+="     - Order expiration: "+TimeToString(trans.time_expiration)+"\r\n";
   desc+="     - Price: "+StringFormat("%G",trans.price)+"\r\n";
   desc+="     - Price trigger: "+StringFormat("%G",trans.price_trigger)+"\r\n";
   desc+="     - Stop Loss: "+StringFormat("%G",trans.price_sl)+"\r\n";
   desc+="     - Take Profit: "+StringFormat("%G",trans.price_tp)+"\r\n";
   desc+="     - Volume: "+StringFormat("%G",trans.volume)+"\r\n";
//--- return the obtained string
   printf(desc);
}


// Print MqlTradeRequest data structure
void printRequest(const MqlTradeRequest &request) {
//---
   string desc="MqlTradeRequest\r\n";
   desc+="     - " + EnumToString(request.action)+"\r\n";
   desc+="     - Symbol: "+request.symbol+"\r\n";
   desc+="     - Magic Number: "+StringFormat("%d",request.magic)+"\r\n";
   desc+="     - Order ticket: "+(string)request.order+"\r\n";
   desc+="     - Order type: "+EnumToString(request.type)+"\r\n";
   desc+="     - Order filling: "+EnumToString(request.type_filling)+"\r\n";
   desc+="     - Order time type: "+EnumToString(request.type_time)+"\r\n";
   desc+="     - Order expiration: "+TimeToString(request.expiration)+"\r\n";
   desc+="     - Price: "+StringFormat("%G",request.price)+"\r\n";
   desc+="     - Deviation points: "+StringFormat("%G",request.deviation)+"\r\n";
   desc+="     - Stop Loss: "+StringFormat("%G",request.sl)+"\r\n";
   desc+="     - Take Profit: "+StringFormat("%G",request.tp)+"\r\n";
   desc+="     - Stop Limit: "+StringFormat("%G",request.stoplimit)+"\r\n";
   desc+="     - Volume: "+StringFormat("%G",request.volume)+"\r\n";
   desc+="     - Comment: "+request.comment+"\r\n";
//--- return the obtained string
   printf(desc);
}

// Print MqlTradeResult data structure 
void printResult(const MqlTradeResult &result) {
//---
   string desc="MqlTradeResult: \r\n";
   desc+="     - Retcode "+(string)result.retcode+"\r\n";
   desc+="     - Request ID: "+StringFormat("%d",result.request_id)+"\r\n";
   desc+="     - Order ticket: "+(string)result.order+"\r\n";
   desc+="     - Deal ticket: "+(string)result.deal+"\r\n";
   desc+="     - Volume: "+StringFormat("%G",result.volume)+"\r\n";
   desc+="     - Price: "+StringFormat("%G",result.price)+"\r\n";
   desc+="     - Ask: "+StringFormat("%G",result.ask)+"\r\n";
   desc+="     - Bid: "+StringFormat("%G",result.bid)+"\r\n";
   desc+="     - Comment: "+result.comment+"\r\n";
//--- return the obtained string
   printf( desc);
}

// return bar open price,

/**
 * Return bar open price
 * @param  {ENUM_TIMEFRAMES}  timeframe   The time frame you specify, e.g.: PERIOD_M1, PERIOD_H1, PERIOD_D1
                                          0 for current time frame open price
 * @return {double}                       open price
 */ 
double getCurrentBarOpenPrice(ENUM_TIMEFRAMES timeframe) {
   double openArray[1] = {0};
   CopyOpen (Symbol(), timeframe, 0, 1, openArray);
   return openArray[0];
}


/**
 * Return deal price of last tick. If error, return 0.
 * @return {double}  
 */
double getLastPrice () {
   MqlTick tick;
   if(SymbolInfoTick(Symbol(),tick)) {
      return tick.last;
      
   }
   else {
      return 0;
   }
}

double getLastAskPrice() {
   MqlTick tick;
   if(SymbolInfoTick(Symbol(),tick)) {
      return tick.ask ;
      
   }
   else {
      return 0;
   }
}


uint limitSell(double amount, ulong magicNumber, double price, double tp, double sl) {
   printf("limit selling %G lot, at %G price, TP %G, SL %G", amount, price, tp, sl);
   
   MqlTradeRequest request = {0};
   request.action = TRADE_ACTION_PENDING;
   request.type   = ORDER_TYPE_SELL_LIMIT;
   request.magic  = magicNumber;
   request.symbol = Symbol();
   request.volume = amount;
   request.price  = price;
   request.sl     = sl;
   request.tp     = tp;
   
   MqlTradeResult result = {0};
   
   ResetLastError();

    if(!OrderSend(request,result)) {
      Print(__FUNCTION__,":",result.retcode);
      return 0; 
    }
    //--- write the server reply to log  
    Print(__FUNCTION__,":",result.comment);
    if(result.retcode==10016) Print(result.bid,result.ask,result.price);
    //--- return code of the trade server reply
    return result.retcode;   
   
}


uint limitBuy(double amount, ulong magicNumber, double price, double tp, double sl) {
   printf("limit buying %G lot, at %G price, TP %G, SL %G", amount, price, tp, sl);
   
   MqlTradeRequest request = {0};
   request.action = TRADE_ACTION_PENDING; //TRADE_ACTION_PENDING;
   request.type   = ORDER_TYPE_BUY_LIMIT;
   request.magic  = magicNumber;
   request.symbol = Symbol();
   request.volume = amount;
   request.price  = price;
   request.sl     = sl;
   request.tp     = tp;
   
   MqlTradeResult result = {0};
   
   ResetLastError();

    if(!OrderSend(request,result)) {
      Print(__FUNCTION__,":",result.retcode);
      return 0; 
    }
    //--- write the server reply to log  
    Print(__FUNCTION__,":",result.comment);
    if(result.retcode==10016) Print(result.bid,result.ask,result.price);
    //--- return code of the trade server reply
    return result.retcode;   
   
}




/**
 * Buy certian lot at market price.
 * @param  {double}  amount   lot size
   @param  {ulong}   magicNumber
   @param  {double}  distance above the market buy price to take profit
 * @return {uint}  Return the retcode of MqlTradeResult
 */
uint marketBuy(double amount, ulong magicNumber, double profit) {
   /*
   printf("buying %f", amount);
   return 1;
   */
   
    printf("buying %f", amount);
    double lastPrice = getLastAskPrice();
    MqlTradeRequest request={0};
    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_BUY;
    request.magic = magicNumber;
    request.symbol = Symbol();
    request.volume = amount;
    request.sl = 0;
    if(profit > 0){
       request.tp = lastPrice+ profit; // lastPrice may not be market buy price
    } else {
      request.tp = 0;
    }
    
    //request.price = 0;
    
    MqlTradeResult result = {0};
    
    ResetLastError();
    
    if(!OrderSend(request,result)) {
      Print(__FUNCTION__,":",result.retcode);
      return 0; 
    }
    //--- write the server reply to log  
    Print(__FUNCTION__,":",result.comment);
    if(result.retcode==10016) Print(result.bid,result.ask,result.price);
    //--- return code of the trade server reply
    return result.retcode; 
}



/**
 * Sell certian lot at market price.
 * @param  {double}  amount   lot size
 * @return {uint}  Return the retcode of MqlTradeResult
 */
uint marketSell(double amount, ulong magicNumber, double profit){
   /*
   printf("selling %f", amount);
   return 1;
   */
    printf("selling %f", amount);
    double lastPrice = getLastAskPrice();
    MqlTradeRequest request={0};
    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_SELL;
    request.magic = magicNumber;
    request.symbol = Symbol();
    request.volume = amount;
    request.sl = 0;
    if(profit > 0){
      request.tp = lastPrice - profit;    
    } else {
      request.tp = 0;
    }
   
    //request.price = 0;
    
    MqlTradeResult result = {0};
    
    ResetLastError();
    
    if(!OrderSend(request,result)) {
      return 0; 
    }
     //--- write the server reply to log  
    Print(__FUNCTION__,":",result.comment);
    if(result.retcode==10016) Print(result.bid,result.ask,result.price);
    //--- return code of the trade server reply
    return result.retcode; 
    
   
}


// position variable in global scope required
void updatePosition(const MqlTradeTransaction& trans, double& iPosition)  {
  
   if(trans.type == TRADE_TRANSACTION_HISTORY_ADD) {
      
      
      if(PositionSelect(Symbol())) {
        
        double symbolPosition = PositionGetDouble(POSITION_VOLUME);
        
        long pType = PositionGetInteger(POSITION_TYPE);
        
        if(pType == POSITION_TYPE_BUY) {
        
            symbolPosition = symbolPosition;   
            
        } else {
        
            symbolPosition = -symbolPosition;
        }
        
        iPosition = symbolPosition;
        printf("position updated to: %f", iPosition);
        
      }  else {
         
         // If position is 0, then PositionSelect() will return false
         iPosition = 0;
      }
   }
}

class LossList: public CList {
};

class OrderCell: public CObject {
   public:
      double openPrice;
      ulong orderId;
      double volume;
      ENUM_ORDER_TYPE orderType;
      datetime fillTime;
      ulong magic;
      double takeProfitPrice;
      double stopLossPrice;
      double movingSpeed;
      double lastPrice;
      
      int preventLossPoint;
                     
      
      int takeProfitPoint;
      
      double bestPrice;
      OrderCell(double price, ulong id, ENUM_ORDER_TYPE orderTypeMy, double orderVolume, ulong theMagic, 
         double tp, double sl) {
         this.openPrice = price;
         printf("OpenPrice in constructor: %G", this.openPrice);
         this.orderId = id;
         this.orderType = orderTypeMy;
         this.volume = orderVolume;
         this.magic = theMagic;
         this.preventLossPoint = 135;
         this.takeProfitPoint = 135*4;
         
         this.takeProfitPrice = tp;
         this.stopLossPrice = sl;
         
         if(orderTypeMy == ORDER_TYPE_BUY) {
            this.bestPrice = 0;  // well below reasonable open price 
            // so that the 1st run of updateBestPrice() will be correct
         }
         if(orderTypeMy == ORDER_TYPE_SELL) {
            this.bestPrice = 100;  // well above reasonalb eopen price
            // so that the 1st run of updateBestPrice() will be correct
         }
         
      };
      void updateBestPrice() {
          double theLastPrice = getLastPrice();
          if(this.orderType == ORDER_TYPE_BUY){
           this.bestPrice = MathMax(this.openPrice, this.bestPrice);
           this.bestPrice = MathMax(this.bestPrice, theLastPrice); 
          }
          if(this.orderType == ORDER_TYPE_SELL){
            this.bestPrice = MathMin(this.bestPrice, this.openPrice);
            this.bestPrice = MathMin(this.bestPrice, theLastPrice);
          
          }
      }
      void preventLoss() {
      
         double currentPrice = getLastPrice();
         
         this.updateBestPrice();
         
          printf("--- The best price is: %f", this.bestPrice);
          printf("--- OpenPrice is: %f", this.openPrice);
          printf("--- current Price is: %f", currentPrice );
          printf("--- last price is: %f", this.lastPrice);
          printf("--- Magic is: %d", this.magic);        
         
         if(this.orderType == ORDER_TYPE_BUY){
            printf("entering ORDER_TYPE_BUY  prvent loss");
            if(this.bestPrice > this.openPrice + this.preventLossPoint*Point()) {
               // based on bestPrice, prevent loss logic start
               printf("prevent loss logic triggered for buy order");
               printf("(this.openPrice + this.preventLossPoint*Point(): %f", (this.openPrice + this.preventLossPoint*Point()));
               printf("this.preventLossPoint*Point()/2: %f", this.preventLossPoint*Point()/2);
               printf("currentPrice - (this.openPrice + this.preventLossPoint*Point()*0.5): %f ",currentPrice - (this.openPrice + this.preventLossPoint*Point()*0.5) );
               printf("currentPrice - this.lastPrice: %f",  currentPrice - this.lastPrice);
               if(currentPrice < (this.openPrice + this.preventLossPoint*Point()*0.5) && currentPrice < this.lastPrice) {
                  // based on current price
                  // 1) between openPrice and openPrice + 1/2*preventLossPoint
                  // 2) moving towards open price, which is currentPrice < this.lastPrice
                  printf("prevent loss triggered - closing order with magic %d", this.magic);
                  marketSell(this.volume, this.magic, 0);
               }
            } else {
               printf("buy order %d prevent loss activation not met", this.magic);
            }
      
         }
         
         if(this.orderType == ORDER_TYPE_SELL){
            printf("entering ORDER_TYPE_SELL prvent loss");
            if(this.bestPrice < this.openPrice - this.preventLossPoint*Point()){
               // prevent loss logic start  
               printf("prevent loss logic triggered for sell order");
               if(currentPrice > (this.openPrice - this.preventLossPoint*Point()*0.5) && currentPrice > this.lastPrice ) {
                  printf("prevent loss triggered - closing order with magic %d", this.magic);
                  marketBuy(this.volume, this.magic, 0);   
               }
            } else {
               printf("sell order %d prevent loss activation not met", this.magic);
            }
         } 
         
         this.lastPrice = currentPrice;
      }
      
      void takeProfit() {
         
         double currentPrice = getLastPrice();
         
         this.updateBestPrice();
         
         if(this.orderType == ORDER_TYPE_BUY){
            if(this.bestPrice - this.openPrice > this.takeProfitPoint*Point() ){
               marketSell(this.volume, this.magic, 0);
            }
         }
         
         if(this.orderType == ORDER_TYPE_SELL){
            if(this.openPrice -this.bestPrice > this.takeProfitPoint*Point() ){
               marketBuy(this.volume, this.magic, 0);   
            }
         }
         
         
      }
      
      void showCellProfit(double closePrice) {

         double pl;
         
         if(this.orderType == ORDER_TYPE_BUY){
            pl = closePrice - this.openPrice;
            printf("-----------------------------------");
            printf("---Buy order completed, profit: %G ---", pl);
            printf("------magic: %d-----------------------------", this.magic);
           
         }
         
         if(this.orderType == ORDER_TYPE_SELL){
            pl = closePrice - this.openPrice;
            printf("-----------------------------------");
            printf("---Sell order completed, profit: %G ---", pl);
            printf("------magic: %d-----------------------------", this.magic);
                        
    
         }        
      }
      
      void logLoss(double closePrice, LossList* list) {
         printf("logLoss triggered");
         double netProfit=0;
         if(this.orderType == ORDER_TYPE_BUY || this.orderType == ORDER_TYPE_BUY_LIMIT) {
            netProfit = closePrice - this.openPrice; 
         }
         
         
         if(this.orderType == ORDER_TYPE_SELL || this.orderType == ORDER_TYPE_SELL_LIMIT) {
            netProfit = this.openPrice - closePrice;
         }
         printf("netProfit is: %G", netProfit);
         if(netProfit < 0) {
            Alert("Loss ", netProfit);
            printf("loss ----------- %G", netProfit);
            printf("closePrice: %G", closePrice);
            printf("openPrice: %G", this.openPrice);
            LossObject *loss = new LossObject(this.magic, -netProfit);
            
            list.Add(loss);
         }
      }
      
      ~OrderCell(void) {printf("destructing OrderCell...");};
};





class TickList: public CList {
    
   public:
   bool saveTickToFile() {
     
      string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);
      string filename = "";
      TickObject *tickObject = this.GetNodeAtIndex(0);
      
      if(tickObject != NULL) {

         datetime tickTime = tickObject.tick.time;
         string dateName = TimeToString(tickTime,TIME_DATE);
         filename = dateName + ".csv";      

      } else {
         int start = 0;
         int count = 2;
         datetime tm[]; // array storing the returned bar time
         //--- copy time 
         CopyTime(_Symbol,PERIOD_D1,start,count,tm);

         filename =  TimeToString(tm[1],TIME_DATE) + ".csv";
         
      }
      
      //printf("filename: " + filename);
      ResetLastError();
      int fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV);
      //printf("fileHandle: %d", fileHandle);
      if(fileHandle != INVALID_HANDLE) {
         // safe to write file here
         // file will be written to sandbox, not absolute path to the OS
         // C:\Users\bobb\AppData\Roaming\MetaQuotes\Tester\158904DFD898D640E9B813D10F9EB397\Agent-127.0.0.1-3001\MQL5\Files
       
         int total = this.Total();
         TickObject * to;
         if(total == 0) {
            string row = "nothing~";
            FileWrite(fileHandle, row);
            
         }
         
         for(int i=0;i<total;i++){
            to = this.GetNodeAtIndex(i);
            string row = "";
            // if you want seconds:  (string)(long)to.tick.time
            StringConcatenate(row, fileHandle,to.tick.time, ", ", DoubleToString(to.tick.last,5) );
            FileWrite(fileHandle, row);
         }
         
         
         FileClose(fileHandle);
         //Print("File Writing successful! ");
      } else {
         Print("Operation FileOpen failed, error: ", GetLastError());
      }
   
      return true;
   }
    
};

class LossObject: public CObject {
   public:
   ulong lossMagic;
   double lossAmount;
   LossObject(ulong m, double l) {
      this.lossMagic = m;
      this.lossAmount = l;
   }
   
};

class TickObject: public CObject {
   
   public:
   TickObject(MqlTick &t) {
      this.tick = t;
   }
   ~TickObject() {
      //printf("removing TickObject");
   }
   MqlTick tick;
   
};




class OrderList: public CList {

   public:
   
   double netPosition;
   LossList *lossList;
   OrderList(LossList*& l) {
      this.netPosition = 0;
      this.lossList = l;
   }
   
   void updatePosition(const MqlTradeTransaction& trans) {

      if(trans.type == TRADE_TRANSACTION_HISTORY_ADD) {
         
         if(PositionSelect(Symbol())) {
           
           double symbolPosition = PositionGetDouble(POSITION_VOLUME);
           
           long pType = PositionGetInteger(POSITION_TYPE);
           
           if(pType == POSITION_TYPE_BUY) {
           
               symbolPosition = symbolPosition;   
               
           } else {
           
               symbolPosition = -symbolPosition;
           }
           
           this.netPosition = symbolPosition;
           printf("position updated to: %f", this.netPosition);
           
         }  else {
            
            // If position is 0, then PositionSelect() will return false
            this.netPosition = 0;
         }
      }
   }

   void updateOrderCells (const MqlTradeTransaction& trans, 
      const MqlTradeRequest& request, 
      const MqlTradeResult& result) {
   
      double orderPrice; // history add
      ulong orderId; // history add
      double orderVolume;
      ENUM_ORDER_TYPE orderType; // history add
      ulong theMagic;
      double stopLoss;
      double takeProfit;
      printf("transaction type: " + EnumToString(trans.type));
      
      if(trans.type == TRADE_TRANSACTION_HISTORY_ADD) {
         //printRequest(request);
         //printResult(result);
         //printTradeTransaction(trans);
      }
      if(trans.type == TRADE_TRANSACTION_REQUEST ) {
         // only 0 data in request and result when TRADE_TRANSACTION_HISTORY_ADD
         // only TRADE_TRANSACTION_REQUEST contains magic
         printf("request.price:   %f", request.price);
         printf("result.order:  %d", result.order);
         printf("request.type:  %s", EnumToString(request.type));
         printf("result.volume: %f", result.volume);
         printf("request.magic %d", request.magic);
      
         orderPrice  = request.price; // 1
         orderId     = result.order; // 2
         orderType   = request.type; // 3
         orderVolume = result.volume;// 4
         theMagic    = request.magic;  // 5
         takeProfit  = request.tp;
         stopLoss    = request.sl;
      
         // if magic is not present, then add order to list
         // if magic is in order list, then remove the order in the list, since
         // it is closing order. 
         if(theMagic == closePositionMagic){
            // magic for closing all open position  
            //cellList.deleteAll(); 
            this.showProfitDeleteAll(orderPrice);
            printf("All order deleted in cellList");
            printf("after removing all order: cellList.Total(): %d", this.Total());
         } else {
            // not 2000, then follow the logic 
               OrderCell *order = findByMagic(request.magic);
               
               if(order != NULL){
                  // if there is order with this magic, then remove it
                  printf("before, cellList.Total(): %d", this.Total());
                  
                  order.logLoss(orderPrice, this.lossList);
                  this.showProfitDelete(request.magic, orderPrice);
                  
                  printf("after, cellList.Total(): %d", this.Total()); 
            
               } else {
                  // no such order exiist, then build new order cell
                  printf("before Add(): cellList.Total(): %d", this.Total());
                  this.Add(new OrderCell(orderPrice, orderId, orderType, orderVolume, request.magic,takeProfit, stopLoss));
                  printf("after Add(): cellList.Total(): %d", this.Total());
               }   
         }
      }
      
      /// when execution from server side, e.g.: take profit or stop loss
      if(trans.type == TRADE_TRANSACTION_HISTORY_ADD) {
         // 1. found by take profit price
             // if  and has opposite direction then
             // log profit, and remove order from this list
         // 2. found by stop loss price
             // if in opposite direction then
             // log loss, and remove the order from the list
         int index[2] = {0};
         index[0] = this.findByTakeProfitPrice(trans.price);
         index[1] = this.findByStopLossPrice(trans.price);
         
         for(int i=0;i<ArraySize( index);i++){

            if(index[i] != -1) {
               // found
               
               printf("found by take profit price, index is: %d ", index[i] );
               
               OrderCell *order = this.GetNodeAtIndex(index[i]);
               // buy direction
               if(order.orderType == ORDER_TYPE_BUY || order.orderType == ORDER_TYPE_BUY_LIMIT) {
                  if(trans.order_type == ORDER_TYPE_SELL ) {
                     // confirmed
                     order.logLoss(trans.price,this.lossList);
                     this.Delete(index[i]);                 
                  }
               }
               // sell direction
               if(order.orderType == ORDER_TYPE_SELL || order.orderType == ORDER_TYPE_SELL_LIMIT) {
                  if(trans.order_type == ORDER_TYPE_BUY ) {
                     // confirmed
                     order.logLoss(trans.price,this.lossList);
                     this.Delete(index[i]);                 
                  }
               }
            }            
         }
      }
   }
   
   int findByTakeProfitPrice(double takeProfit) {
      OrderCell *order = NULL;
      int total = this.Total();
      
      for(int i=0;i<total;i++){
         order = this.GetNodeAtIndex(i);
         string str1 = DoubleToString(order.takeProfitPrice, 5);
         string str2 = DoubleToString(takeProfit,5);
         
         if( StringCompare(str1,str2) == 0) {
            // equal
            return i;
         }     
      }
      
      return -1;
   }
   
   int findByStopLossPrice(double stopLoss) {

      OrderCell *order = NULL;
      int total = this.Total();
      
      for(int i=0;i<total;i++){
         order = this.GetNodeAtIndex(i);
         string str1 = DoubleToString(order.stopLossPrice, 5);
         string str2 = DoubleToString(stopLoss,5);
         
         if( StringCompare(str1, str2) == 0) {
            // equal
            return i;
         }     
      }
      
      return -1;
   
   }
   
   void preventLoss() {
      int total = this.Total();
      if(total == 0) {
         return;   
      }
      OrderCell *cell;
      for(int i=0;i<total;i++){
         cell = this.GetNodeAtIndex(i);
         cell.preventLoss();
            
      }
   
   }
   
   void takeProfit () {

      int total = this.Total();
      if(total == 0) {
         return;   
      }
      OrderCell *cell;
      for(int i=0;i<total;i++){
         cell = this.GetNodeAtIndex(i);
         cell.takeProfit();
            
      }   
   
   }
   
   void showProfitDelete(ulong magic, double closePrice ) {
      int total = this.Total();
      for(int i=0;i< total;i++){
         OrderCell *cell = this.GetNodeAtIndex(i);
         
         if(cell.magic == magic) {
            
           cell.showCellProfit(closePrice);
           
           this.Delete(i);
         }
            
      }      
   }
   
   void showProfitDeleteAll(double closePrice) {

      int total = this.Total();
      OrderCell* cell;
      for(int i=total;i> 0;i--){
         cell = this.GetNodeAtIndex(i-1);
         cell.showCellProfit(closePrice);
         this.Delete(i - 1);   
      }
   }
   
   int deleteByMagic(ulong magic) {
      int total = this.Total();
      for(int i=0;i< total;i++){
         OrderCell *cell = this.GetNodeAtIndex(i);
         
         if(cell.magic == magic) {
            this.Delete(i);
            return i;
         }
            
      }
      return -1;
   } 
   
   void deleteAll() {

      int total = this.Total();
      for(int i=total;i> 0;i--){
         this.Delete(i - 1);   
      }
   
   }
   
   bool checkDuplicateMagic() {
      return false;
   }
   
   OrderCell* findByMagic (ulong magic) {
   
      int total = this.Total();
      for(int i = 0; i< total; i++ ) {
         OrderCell *cell = this.GetNodeAtIndex(i);
         if(cell.magic == magic ) {
            return cell;
         }
      }
      return NULL;
   }
};

void printList(CList& list) {

   int total = list.Total();
   if(total > 0){
      for(int i=0;i<total;i++){
         OrderCell *cell = list.GetNodeAtIndex(i);
         printf("----------------------");
         printf("   - cell.magic: %d", cell.magic);
         printf("   - Order Index: %d", i);
         printf("-----------------------");
      }
   } else {
      printf("----------Empty Order List------");
   }

}