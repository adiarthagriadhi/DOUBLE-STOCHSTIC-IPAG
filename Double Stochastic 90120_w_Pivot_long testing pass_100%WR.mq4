//+------------------------------------------------------------------+
//|                                      Double Stochastic 90120.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

//----------------------------+
// Parameter Stochastic       |
//----------------------------+


  double sto90b  = iStochastic(NULL, PERIOD_H1,90,5,3,2,STO_LOWHIGH,MODE_MAIN,1);
  double sto90a  = iStochastic(NULL, PERIOD_H1,90,5,3,2,STO_LOWHIGH,MODE_MAIN,2);
  double sto120b = iStochastic(NULL, PERIOD_H4,120,5,3,2,STO_LOWHIGH,MODE_MAIN,1);
  double sto120a = iStochastic(NULL, PERIOD_H4,120,5,3,2,STO_LOWHIGH,MODE_MAIN,2);
  double sto300  = iStochastic(NULL, PERIOD_H4,300,5,3,2,STO_LOWHIGH,MODE_MAIN,0);
  double sto300b = iStochastic(NULL, PERIOD_H4,300,5,3,2,STO_LOWHIGH,MODE_MAIN,1);
  double sto300a = iStochastic(NULL, PERIOD_H4,300,5,3,2,STO_LOWHIGH,MODE_MAIN,2);

//----------------------------+
// General                    |
//----------------------------+

int Order = SIGNAL_NONE;
int Total;
Total = OrdersTotal ();  
if (Volume[0]>1) return;

//----------------------------+
// Sizing Risk dan Volume     |
//----------------------------+
 
bool isSizingOn = true;

double Risk = 5; 
double Lots = 1.0; 

int StopLoss = 100;
int P = 10;

 if (isSizingOn == true) 
 {
      Lots = Risk * 0.01 * AccountBalance() / (MarketInfo(Symbol(),MODE_LOTSIZE) * StopLoss * P * Point); // Sizing Algo based on account size
      Lots = NormalizeDouble(Lots, 2); // Round to 2 decimal place
 } 
 

//========================//
// TRADING SIGNAL         //
//========================//
//----------------------------+
// Expired time pending order |
//----------------------------+

datetime et1 = TimeCurrent()+(PERIOD_H1*60)*60;
datetime et2 = TimeCurrent()+(PERIOD_H1*60)*60;

//-------------------------+
// Open Signal Stochastic  |
//-------------------------+   
   
int OpenSig = 99;
int Tot = OrdersTotal ();  

//-------------------------------------+
// Nilai Highest,Low dan Pivot (26/52) |
//-------------------------------------+

double Hig1  = High[iHighest(NULL, PERIOD_H1, MODE_HIGH,26,1)];
double Lo1   = Low[iLowest(NULL, PERIOD_H1, MODE_LOW, 26,1)];
double Hig2  = High[iHighest(NULL, PERIOD_H1, MODE_HIGH,52,1)];
double Lo2   = Low[iLowest(NULL, PERIOD_H1, MODE_LOW, 52,1)];
double pivotH152 = Low[iLowest(NULL, PERIOD_H1, MODE_LOW, 52,1)]+NormalizeDouble((High[iHighest(NULL, PERIOD_H1, MODE_HIGH,52,1)]-Low[iLowest(NULL, PERIOD_H1, MODE_LOW, 52,1)])/2,5);
double MA26a = iMA(NULL, PERIOD_CURRENT,26,0,MODE_SMA,PRICE_MEDIAN,5);
double MA26b = iMA(NULL, PERIOD_CURRENT,26,0,MODE_SMA,PRICE_MEDIAN,1);



if (sto90a < 20 && sto90b >=20) OpenSig = 0;
if (sto90a > 80 && sto90b <=80) OpenSig = 1;

if (OpenSig == 0 && Ask <= pivotH152 && MA26a < MA26b) 
{
int Ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask - 10000*Point, Ask + 700*Point,"Stochastic");
int Ticketa = OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask + 80*Point,3,Ask - 10000*Point, Ask + 600*Point,"Stochastic1",0);
int Ticketb = OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask + 120*Point,3,Ask - 10000*Point, Ask + 400*Point,"Stochastic2",0);

}

if (OpenSig == 1  && Bid >= pivotH152 && MA26a > MA26b) 
{
int Ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + 10000*Point, Bid - 700*Point,"Stochastic"); 
int Ticketc = OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid - 80*Point,3,Bid + 10000*Point, Bid - 600*Point,"Stochastic1"); 
int Ticketd = OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid- 120 * Point,3,Bid + 10000*Point, Bid - 400*Point,"Stochastic2");    
}   

/*
//----------------------//
// GRID SCALPING        //
//----------------------//  


//----------------------------+
// Filter position dari akun  |
//----------------------------+

if (Tot >=25) return;
double B = (AccountInfoDouble(ACCOUNT_BALANCE)- AccountInfoDouble(ACCOUNT_EQUITY))/ AccountInfoDouble(ACCOUNT_BALANCE);
if (B >=0.001) return;





int Tiket3x = OrderSend(Symbol(),OP_SELLLIMIT,Lots,Hig1,3,Hig1 + 1000*Point,Hig1-600*Point,"Grid Scalping26x",0,et1);
//int Tiket3a = OrderSend(Symbol(),OP_BUYSTOP,Lots,NormalizeDouble(Hig2,5),3,NormalizeDouble(Hig2,5)- 10000*Point, NormalizeDouble(Hig2,5)+ 600*Point,"Grid Scalping52",0,et2);
int Tiket3ax = OrderSend(Symbol(),OP_SELLLIMIT,Lots,Hig2,3,Hig2 + 1000*Point,Hig2 - 600*Point,"Grid Scalping52x",0,et2);


int Tiket4x = OrderSend(Symbol(),OP_BUYLIMIT,Lots,Lo1,3,Lo1 - 1000*Point, Lo1 + 600*Point ,"Grid Scalping26x",0,et1);
//int Tiket4a = OrderSend(Symbol(),OP_SELLSTOP,Lots,NormalizeDouble(Lo2,5),3,NormalizeDouble(Lo2,5) + 10000*Point, NormalizeDouble(Lo2,5) - 600*Point,"Grid Scalping52",0,et2);
 int Tiket4ax = OrderSend(Symbol(),OP_BUYLIMIT,Lots,Lo2,3,Lo2 - 1000*Point, Lo1 + 600*Point,"Grid Scalping52x",0,et2);


//Open Sell Stop
if (Close[1] < pivotH152) int Tiket4 = OrderSend(Symbol(),OP_SELL,Lots,Lo1,3,Lo1+ 1000*Point, Lo1-600*Point,"Grid Scalping26",0,et1);
//Open Buy Stop
if (Close[1] > pivotH152)int Tiket3 = OrderSend(Symbol(),OP_BUY,Lots,Hig1,3,Hig1-1000*Point, Hig1+600*Point,"Grid Scalping26",0,et1);

Print (Hig2,"___",Lo2,"___",pivotH152);
*/

  }
//+------------------------------------------------------------------+
