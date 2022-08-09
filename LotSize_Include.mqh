//+------------------------------------------------------------------+
//|                                              LotSize_Include.mqh |
//|                                                Jesper Markenstam |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jesper Markenstam"
#property link      "https://www.mql5.com"
#property strict

// LotSize returns an mt4 type lot size which aims to be close to trading
// with no leverage, i.e. 1:1. This prevents over or under exposure
// consistently, and can be used in a compound interest kind of way,
// as you will automatically trade a larger lot size when the account
// balance grows.

// instrument = GBPUSD for example
// risk = AccountBalance() for example, or if you trade with leverage,
//        AccountBalance()*10 perhaps.
double LotSize(string instrument, double risk) 
  {
   double lots=0;
   int _contractsize;
   string _margincurrency,_basecurrency,_profitcurrency;
   _contractsize = (int)SymbolInfoDouble(instrument,SYMBOL_TRADE_CONTRACT_SIZE);
   _margincurrency = SymbolInfoString(instrument,SYMBOL_CURRENCY_MARGIN);
   _basecurrency = AccountCurrency();
   _profitcurrency = SymbolInfoString(instrument,SYMBOL_CURRENCY_PROFIT);

   if ( _margincurrency == _profitcurrency ) {   
      if ( _basecurrency != _profitcurrency ) {
         lots = risk / ( _contractsize * iClose(instrument,PERIOD_D1,1) / iClose(StringConcatenate(_basecurrency,_profitcurrency),PERIOD_D1,1) );
      } else {
         lots = risk / ( _contractsize * iClose(instrument,PERIOD_D1,1) );
      }         
   }

   if ( _margincurrency != _profitcurrency ) {
      if ( _basecurrency == _margincurrency ) {
         lots = risk / _contractsize;
      } else {
         lots = risk * iClose(StringConcatenate(_basecurrency,_margincurrency),PERIOD_D1,1) / _contractsize;   
      }
   } 
   return lots;
  }

// MarketAdjustedLotSize calculates the size needed by the broker to trade a given instrument,
// e.g. for SP500 on Admiral Markets the smallest size is 0.10 so if LotSize returns 1.22 lots
// which does not fit into multiples of 0.10, we can use below to send a size of say
// 1.20 instead of 1.22.
double MarketAdjustedLotSize(string instrument, double risk)
  {
   double lots=0;
   lots = NormalizeDouble(LotSize(instrument,risk)/SymbolInfoDouble(instrument,SYMBOL_VOLUME_MIN),0) * SymbolInfoDouble(instrument,SYMBOL_VOLUME_MIN);
   return lots;
  }
