//+------------------------------------------------------------------+
//|                                                    lrAdvisor.mq5 |
//|                                                        NicolasXu |
//|                                       https://www.noWebsite5.com |
//+------------------------------------------------------------------+
#property copyright "NicolasXu"
#property link      "https://www.noWebsite5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function        
//+------------------------------------------------------------------+

#include "OnNewBar.mqh"
#include "Utilities.mqh"
// Global value

double         buySignalBuffer[];
double         sellSignalBuffer[];
double         amaBuffer[];
double         jjmaBuffer[];


OrderList *cellList;
int globalMagic = 1000;
 




int            akmaHandle;
int            jjmaHandle;

double         position = 0;
double         positionOpenPrice = 0;
double         barOpenPrice = 0;
ENUM_TIMEFRAMES targetTimeFrame = PERIOD_D1;

// current position

input double   positionIncrementalSize = 0.1;


CisNewBar fiveMinBar;

int OnInit() {

      double myPoint = Point();
      printf("a point is: %f", myPoint);
      
     //--- create timer
     EventSetTimer(60*5);
 
     akmaHandle = iCustom(NULL,0,"Expert_Indicators\\amka", 9, 2, 30, 2.0, 0, 1.0 );
     jjmaHandle = iCustom(NULL,0,"Expert_Indicators\\jjma", 7, 100, PRICE_WEIGHTED,0,0);
     
     ArraySetAsSeries(buySignalBuffer,true);
     ArraySetAsSeries(sellSignalBuffer,true); 
     ArraySetAsSeries(amaBuffer, true);
         
     PrintFormat("akmaHandle handle number: %d",  akmaHandle);
     PrintFormat("jjmaHandle handle number: %d",  jjmaHandle);
     
     cellList = new OrderList;
     if(cellList == NULL) {
        printf("Init CList error");
        return INIT_FAILED;   
     }
     
     return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
int timerCount = 1;
void OnTimer() {
   // every 5 min
   //printf("OnTimer() triggered: %d", timerCount);
   
//   if(timerCount == 5){
//      marketBuy(positionIncrementalSize, globalMagic++);
//   }
   
   timerCount++;
   cellList.takeProfit();
   //cellList.preventLoss();
  
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   IndicatorRelease(akmaHandle);
   delete cellList;
      
}



//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade() {
//---
   
}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)  {
  
// 1. TRADE_TRANSACTION_DEAL_ADD
// 2. TRADE_TRANSACTION_REQUEST, request contain order magic, result contains order id, price

   updatePosition(trans, position);
   
   cellList.updateOrderCells(trans, request, result);
   
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
//---
   double ret=0.0;
//---

//---
   return(ret);
}
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit() {
//---
   
}
  
void OnTesterDeinit() {
  
}
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass() {
//---
   
}
//+------------------------------------------------------------------+

void OnEveryTick() {
    //printf("every tick...OnEveryTick()");
}



//+------------------------------------------------------------------+
//| New bar event handler function                                   |
//+------------------------------------------------------------------+
void OnNewBar() {
   
    
   
   if(CopyBuffer(akmaHandle,0 , 0, 4, amaBuffer ) && 
      CopyBuffer(akmaHandle,1 , 0, 3, sellSignalBuffer ) && 
      CopyBuffer(akmaHandle,2 , 0, 3, buySignalBuffer ) &&
      CopyBuffer(jjmaHandle,0, 0, 4, jjmaBuffer)) {
      if(sellSignalBuffer[1] > 0){
         printf("sell signal %f", sellSignalBuffer[1]);
      
         if(position > 0){
            marketSell(position, closePositionMagic);
         }
            marketSell(positionIncrementalSize, globalMagic++); 
      }

      if(buySignalBuffer[1] > 0){
         printf("buy signal %f", buySignalBuffer[1]);
         if(position < 0){
            marketBuy(-position, closePositionMagic);   
         }
            marketBuy(positionIncrementalSize, globalMagic++);
      }
      
      // detect trend reverse 
      // 3 , 2 , 1 , 0
      if( (amaBuffer[3] - amaBuffer[2] > 0) && (amaBuffer[2] -  amaBuffer[1] < 0) ){
         
         // close all position
            printf("trend reversed - to upwards");
         if(position < 0){
            printf("closing all position: %f", position);
            marketBuy(-position, closePositionMagic);
         }
      }
      
      if( (amaBuffer[3] - amaBuffer[2] < 0) && (amaBuffer[2] -  amaBuffer[1] > 0) ){
         
         // close all position
         printf("trend reversed - to downwards"); 
         if(position > 0){
             printf("closing all position: %f", position);
             marketSell(position, closePositionMagic);
         }  
      } 
   }  
   
}