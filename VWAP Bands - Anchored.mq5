//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "VWAP Bands - Anchored"

#property indicator_chart_window
#property indicator_buffers 49
#property indicator_plots   49

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_method {
   Close,
   Open,
   High,
   Low,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted // Weighted Close (HLCC/4)
};

enum mode {
   Fibo,
   Percent,
   Stdev
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input group "****************************  VWAP  ****************************"
input string                     vwapID    = "1";       // VWAP ID  (must be unique)
input PRICE_method               method    = Typical;    // Price Calculation method
input color                      vwapColor = Fuchsia;    // VWAP Color
input int                        arrowSize = 2;          // Arrow Size
input ENUM_ARROW_ANCHOR          Anchor    = ANCHOR_TOP; // Arrow Anchor Point
input ENUM_APPLIED_VOLUME        applied_volume = VOLUME_REAL; // tipo de volume
input int                        WaitMilliseconds  = 5000;   // Timer (milliseconds) for recalculation
input mode                       input_mode = Stdev;

input group "****************************  VWAP BANDS  ****************************"
input int                        offset = 0;   // Offset das bandas
input double                     tamanho_banda = 0.33;   // Tamanho padrão das bandas
input color                      vwapColorUp = clrDimGray;    // Cor banda superior
input color                      vwapColorDown = clrDimGray;    // Cor banda inferior
input int                        espessura_linha = 1;   // Espessura das linhas
input ENUM_LINE_STYLE            lineStyle = STYLE_SOLID;    // Estilo das linhas

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double         vwapBuffer[];
double         vwapBandmais1[], vwapBandmais2[], vwapBandmais3[], vwapBandmais4[], vwapBandmais5[], vwapBandmais6[], vwapBandmais7[], vwapBandmais8[], vwapBandmais9[], vwapBandmais10[], vwapBandmais11[], vwapBandmais12[];
double         vwapBandmais13[], vwapBandmais14[], vwapBandmais15[], vwapBandmais16[], vwapBandmais17[], vwapBandmais18[], vwapBandmais19[], vwapBandmais20[], vwapBandmais21[], vwapBandmais22[], vwapBandmais23[], vwapBandmais24[];
double         vwapBandmenos1[], vwapBandmenos2[], vwapBandmenos3[], vwapBandmenos4[], vwapBandmenos5[], vwapBandmenos6[], vwapBandmenos7[], vwapBandmenos8[], vwapBandmenos9[], vwapBandmenos10[], vwapBandmenos11[], vwapBandmenos12[];
double         vwapBandmenos13[], vwapBandmenos14[], vwapBandmenos15[], vwapBandmenos16[], vwapBandmenos17[], vwapBandmenos18[], vwapBandmenos19[], vwapBandmenos20[], vwapBandmenos21[], vwapBandmenos22[], vwapBandmenos23[], vwapBandmenos24[];

//--- global variables
int            startVWAP;
string         prefix;

datetime       arrayTime[];
double         arrayOpen[], arrayHigh[], arrayLow[], arrayClose[];
long           obj_time;
bool           first = true;
int            counter = 0;
double A, B, stdev;

int barras_visiveis, teste;
datetime Hposition;
double   Vposition;
int totalRates;

ENUM_ARROW_ANCHOR ancoragem = Anchor;
double tamanho_banda_calculada = (double)tamanho_banda / 100;
string tipo_vwap = "Typical";
PRICE_method metodo_vwap = method;

//+------------------------------------------------------------------+
//| iBarShift2() function                                             |
//+------------------------------------------------------------------+
int iBarShift2(string symbol, ENUM_TIMEFRAMES timeframe, datetime time) {
   if(time < 0) {
      return(-1);
   }
   datetime Arr[], time1;

   time1 = (datetime)SeriesInfoInteger(symbol, timeframe, SERIES_LASTBAR_DATE);

   if(CopyTime(symbol, timeframe, time, time1, Arr) > 0) {
      int size = ArraySize(Arr);
      return(size - 1);
   } else {
      return(-1);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0, vwapBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "VWAP");
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, espessura_linha);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, lineStyle);

   SetIndexBuffer(1, vwapBandmais1, INDICATOR_DATA);
   SetIndexBuffer(2, vwapBandmais2, INDICATOR_DATA);
   SetIndexBuffer(3, vwapBandmais3, INDICATOR_DATA);
   SetIndexBuffer(4, vwapBandmais4, INDICATOR_DATA);
   SetIndexBuffer(5, vwapBandmais5, INDICATOR_DATA);
   SetIndexBuffer(6, vwapBandmais6, INDICATOR_DATA);
   SetIndexBuffer(7, vwapBandmais7, INDICATOR_DATA);
   SetIndexBuffer(8, vwapBandmais8, INDICATOR_DATA);
   SetIndexBuffer(9, vwapBandmais9, INDICATOR_DATA);
   SetIndexBuffer(10, vwapBandmais10, INDICATOR_DATA);
   SetIndexBuffer(11, vwapBandmais11, INDICATOR_DATA);
   SetIndexBuffer(12, vwapBandmais12, INDICATOR_DATA);
   SetIndexBuffer(13, vwapBandmais13, INDICATOR_DATA);
   SetIndexBuffer(14, vwapBandmais14, INDICATOR_DATA);
   SetIndexBuffer(15, vwapBandmais15, INDICATOR_DATA);
   SetIndexBuffer(16, vwapBandmais16, INDICATOR_DATA);
   SetIndexBuffer(17, vwapBandmais17, INDICATOR_DATA);
   SetIndexBuffer(18, vwapBandmais18, INDICATOR_DATA);
   SetIndexBuffer(19, vwapBandmais19, INDICATOR_DATA);
   SetIndexBuffer(20, vwapBandmais20, INDICATOR_DATA);
   SetIndexBuffer(21, vwapBandmais21, INDICATOR_DATA);
   SetIndexBuffer(22, vwapBandmais22, INDICATOR_DATA);
   SetIndexBuffer(23, vwapBandmais23, INDICATOR_DATA);
   SetIndexBuffer(24, vwapBandmais24, INDICATOR_DATA);

   SetIndexBuffer(25, vwapBandmenos1, INDICATOR_DATA);
   SetIndexBuffer(26, vwapBandmenos2, INDICATOR_DATA);
   SetIndexBuffer(27, vwapBandmenos3, INDICATOR_DATA);
   SetIndexBuffer(28, vwapBandmenos4, INDICATOR_DATA);
   SetIndexBuffer(29, vwapBandmenos5, INDICATOR_DATA);
   SetIndexBuffer(30, vwapBandmenos6, INDICATOR_DATA);
   SetIndexBuffer(31, vwapBandmenos7, INDICATOR_DATA);
   SetIndexBuffer(32, vwapBandmenos8, INDICATOR_DATA);
   SetIndexBuffer(33, vwapBandmenos9, INDICATOR_DATA);
   SetIndexBuffer(34, vwapBandmenos10, INDICATOR_DATA);
   SetIndexBuffer(35, vwapBandmenos11, INDICATOR_DATA);
   SetIndexBuffer(36, vwapBandmenos12, INDICATOR_DATA);
   SetIndexBuffer(37, vwapBandmenos13, INDICATOR_DATA);
   SetIndexBuffer(38, vwapBandmenos14, INDICATOR_DATA);
   SetIndexBuffer(39, vwapBandmenos15, INDICATOR_DATA);
   SetIndexBuffer(40, vwapBandmenos16, INDICATOR_DATA);
   SetIndexBuffer(41, vwapBandmenos17, INDICATOR_DATA);
   SetIndexBuffer(42, vwapBandmenos18, INDICATOR_DATA);
   SetIndexBuffer(43, vwapBandmenos19, INDICATOR_DATA);
   SetIndexBuffer(44, vwapBandmenos20, INDICATOR_DATA);
   SetIndexBuffer(45, vwapBandmenos21, INDICATOR_DATA);
   SetIndexBuffer(46, vwapBandmenos22, INDICATOR_DATA);
   SetIndexBuffer(47, vwapBandmenos23, INDICATOR_DATA);
   SetIndexBuffer(48, vwapBandmenos24, INDICATOR_DATA);

   for(int i = 1; i <= 24; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, vwapColorUp);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP " + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha - 2);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, lineStyle);
   }

   for(int i = 25; i <= 48; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, vwapColorDown);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP " + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha - 2);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, lineStyle);
   }

   prefix = "Obj_" + vwapID;

   datetime timeArrow = GetObjectTime1(prefix);

   if (timeArrow == 0) {
      CreateObject();
   }
   CustomizeObject();
   ChartRedraw();

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   delete(_updateTimer);
// Exclui o Objeto quando o indicador é excluído.
   if(reason != REASON_PARAMETERS && reason != REASON_CHARTCHANGE) {
      ObjectDelete(0, prefix);
      ChartRedraw(0);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if(id == CHARTEVENT_OBJECT_DRAG && sparam == prefix) {
      // Identifica a posição horizontal do objeto
      _lastOK = false;
      CheckTimer();
   }

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      ChartRedraw();
      CheckTimer();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return(1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   startVWAP = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix, OBJPROP_TIME)) + 1;
   totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);

// Calcula a VWAP
   CalculateVWAP();
   return(true);

}

//+------------------------------------------------------------------+
void CalculateVWAP() {

   ArrayInitialize(vwapBuffer, 0);

   ArrayInitialize(vwapBandmais1, 0);
   ArrayInitialize(vwapBandmais2, 0);
   ArrayInitialize(vwapBandmais3, 0);
   ArrayInitialize(vwapBandmais4, 0);
   ArrayInitialize(vwapBandmais5, 0);
   ArrayInitialize(vwapBandmais6, 0);
   ArrayInitialize(vwapBandmais7, 0);
   ArrayInitialize(vwapBandmais8, 0);
   ArrayInitialize(vwapBandmais9, 0);
   ArrayInitialize(vwapBandmais10, 0);
   ArrayInitialize(vwapBandmais11, 0);
   ArrayInitialize(vwapBandmais12, 0);
   ArrayInitialize(vwapBandmais13, 0);
   ArrayInitialize(vwapBandmais14, 0);
   ArrayInitialize(vwapBandmais15, 0);
   ArrayInitialize(vwapBandmais16, 0);
   ArrayInitialize(vwapBandmais17, 0);
   ArrayInitialize(vwapBandmais18, 0);
   ArrayInitialize(vwapBandmais19, 0);
   ArrayInitialize(vwapBandmais20, 0);
   ArrayInitialize(vwapBandmais21, 0);
   ArrayInitialize(vwapBandmais22, 0);
   ArrayInitialize(vwapBandmais23, 0);
   ArrayInitialize(vwapBandmais24, 0);

   ArrayInitialize(vwapBandmenos1, 0);
   ArrayInitialize(vwapBandmenos2, 0);
   ArrayInitialize(vwapBandmenos3, 0);
   ArrayInitialize(vwapBandmenos4, 0);
   ArrayInitialize(vwapBandmenos5, 0);
   ArrayInitialize(vwapBandmenos6, 0);
   ArrayInitialize(vwapBandmenos7, 0);
   ArrayInitialize(vwapBandmenos8, 0);
   ArrayInitialize(vwapBandmenos9, 0);
   ArrayInitialize(vwapBandmenos10, 0);
   ArrayInitialize(vwapBandmenos11, 0);
   ArrayInitialize(vwapBandmenos12, 0);
   ArrayInitialize(vwapBandmenos13, 0);
   ArrayInitialize(vwapBandmenos14, 0);
   ArrayInitialize(vwapBandmenos15, 0);
   ArrayInitialize(vwapBandmenos16, 0);
   ArrayInitialize(vwapBandmenos17, 0);
   ArrayInitialize(vwapBandmenos18, 0);
   ArrayInitialize(vwapBandmenos19, 0);
   ArrayInitialize(vwapBandmenos20, 0);
   ArrayInitialize(vwapBandmenos21, 0);
   ArrayInitialize(vwapBandmenos22, 0);
   ArrayInitialize(vwapBandmenos23, 0);
   ArrayInitialize(vwapBandmenos24, 0);

   ArraySetAsSeries(vwapBandmais1, true);
   ArraySetAsSeries(vwapBandmais2, true);
   ArraySetAsSeries(vwapBandmais3, true);
   ArraySetAsSeries(vwapBandmais4, true);
   ArraySetAsSeries(vwapBandmais5, true);
   ArraySetAsSeries(vwapBandmais6, true);
   ArraySetAsSeries(vwapBandmais7, true);
   ArraySetAsSeries(vwapBandmais8, true);
   ArraySetAsSeries(vwapBandmais9, true);
   ArraySetAsSeries(vwapBandmais10, true);
   ArraySetAsSeries(vwapBandmais11, true);
   ArraySetAsSeries(vwapBandmais12, true);
   ArraySetAsSeries(vwapBandmais13, true);
   ArraySetAsSeries(vwapBandmais14, true);
   ArraySetAsSeries(vwapBandmais15, true);
   ArraySetAsSeries(vwapBandmais16, true);
   ArraySetAsSeries(vwapBandmais17, true);
   ArraySetAsSeries(vwapBandmais18, true);
   ArraySetAsSeries(vwapBandmais19, true);
   ArraySetAsSeries(vwapBandmais20, true);
   ArraySetAsSeries(vwapBandmais21, true);
   ArraySetAsSeries(vwapBandmais22, true);
   ArraySetAsSeries(vwapBandmais23, true);
   ArraySetAsSeries(vwapBandmais24, true);

   ArraySetAsSeries(vwapBandmenos1, true);
   ArraySetAsSeries(vwapBandmenos2, true);
   ArraySetAsSeries(vwapBandmenos3, true);
   ArraySetAsSeries(vwapBandmenos4, true);
   ArraySetAsSeries(vwapBandmenos5, true);
   ArraySetAsSeries(vwapBandmenos6, true);
   ArraySetAsSeries(vwapBandmenos7, true);
   ArraySetAsSeries(vwapBandmenos8, true);
   ArraySetAsSeries(vwapBandmenos9, true);
   ArraySetAsSeries(vwapBandmenos10, true);
   ArraySetAsSeries(vwapBandmenos11, true);
   ArraySetAsSeries(vwapBandmenos12, true);
   ArraySetAsSeries(vwapBandmenos13, true);
   ArraySetAsSeries(vwapBandmenos14, true);
   ArraySetAsSeries(vwapBandmenos15, true);
   ArraySetAsSeries(vwapBandmenos16, true);
   ArraySetAsSeries(vwapBandmenos17, true);
   ArraySetAsSeries(vwapBandmenos18, true);
   ArraySetAsSeries(vwapBandmenos19, true);
   ArraySetAsSeries(vwapBandmenos20, true);
   ArraySetAsSeries(vwapBandmenos21, true);
   ArraySetAsSeries(vwapBandmenos22, true);
   ArraySetAsSeries(vwapBandmenos23, true);
   ArraySetAsSeries(vwapBandmenos24, true);

   long VolumeBuffer[];

   if (applied_volume == VOLUME_TICK) {
      teste = CopyTickVolume(_Symbol, 0, 0, startVWAP, VolumeBuffer);
   } else if (applied_volume == VOLUME_REAL) {
      teste = CopyRealVolume(_Symbol, 0, 0, startVWAP, VolumeBuffer);
   }

// Calcula a VWAP
   double sumPrice = 0, sumVol = 0, vwap = 0;
   double tempArray[];
   if(method == Open) {
      teste = CopyOpen(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayOpen);
      ArraySetAsSeries(arrayOpen, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += arrayOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == High) {
      teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayHigh);
      ArraySetAsSeries(arrayHigh, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Low) {
      teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayLow);
      ArraySetAsSeries(arrayLow, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Median) {
      teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayLow);
      teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayHigh);
      ArraySetAsSeries(arrayLow, true);
      ArraySetAsSeries(arrayHigh, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i]) / 2) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Typical) {
      teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayLow);
      teste = CopyClose(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayClose);
      teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayHigh);
      ArraySetAsSeries(arrayLow, true);
      ArraySetAsSeries(arrayClose, true);
      ArraySetAsSeries(arrayHigh, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      ArrayResize(tempArray, startVWAP);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
         tempArray[i] = ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3);
      }
      ArraySetAsSeries(tempArray, true);
      stdev = GetStdDev(tempArray, startVWAP - 1, 0); //calculate standand deviation
      //int a=0;
      //output=(high[index]+low[index]+close[index])/3;
   } else if(method == Weighted) {
      teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayHigh);
      teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayLow);
      teste = CopyClose(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayClose);
      ArraySetAsSeries(arrayLow, true);
      ArraySetAsSeries(arrayClose, true);
      ArraySetAsSeries(arrayHigh, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i] + arrayClose[i]) / 4) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
   } else {
      teste = CopyClose(_Symbol, PERIOD_CURRENT, 0, startVWAP, arrayClose);
      ArraySetAsSeries(arrayClose, true);
      ArraySetAsSeries(VolumeBuffer, true);
      ArraySetAsSeries(vwapBuffer, true);
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         sumPrice    += arrayClose[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         vwapBuffer[i] = sumPrice / sumVol;
      }
      //CalcAB(arrayOpen, startVWAP - 1, 0, A, B);
      stdev = GetStdDev(arrayClose, startVWAP - 1, 0); //calculate standand deviation
   }

   double amplitude = 0;
   double fator = 0;
   if (input_mode == Fibo) {
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         vwap = vwapBuffer[i];
         amplitude = vwap - vwapBuffer[startVWAP - 1];
         fator = 0.1 * amplitude;

         vwapBandmais24[i] = vwap + ((24 + offset) * fator);
         vwapBandmais23[i] = vwap + ((23 + offset) * fator);
         vwapBandmais22[i] = vwap + ((22 + offset) * fator);
         vwapBandmais21[i] = vwap + ((21 + offset) * fator);
         vwapBandmais20[i] = vwap + ((20 + offset) * fator);
         vwapBandmais19[i] = vwap + ((19 + offset) * fator);
         vwapBandmais18[i] = vwap + ((18 + offset) * fator);
         vwapBandmais17[i] = vwap + ((17 + offset) * fator);
         vwapBandmais16[i] = vwap + ((16 + offset) * fator);
         vwapBandmais15[i] = vwap + ((15 + offset) * fator);
         vwapBandmais14[i] = vwap + ((14 + offset) * fator);
         vwapBandmais13[i] = vwap + ((13 + offset) * fator);
         vwapBandmais12[i] = vwap + ((12 + offset) * fator);
         vwapBandmais11[i] = vwap + ((11 + offset) * fator);
         vwapBandmais10[i] = vwap + ((10 + offset) * fator);
         vwapBandmais9[i] = vwap + ((9 + offset) * fator);
         vwapBandmais8[i] = vwap + ((8 + offset) * fator);
         vwapBandmais7[i] = vwap + ((7 + offset) * fator);
         vwapBandmais6[i] = vwap + ((6 + offset) * fator);
         vwapBandmais5[i] = vwap + ((5 + offset) * fator);
         vwapBandmais4[i] = vwap + ((4 + offset) * fator);
         vwapBandmais3[i] = vwap + ((3 + offset) * fator);
         vwapBandmais2[i] = vwap + ((2 + offset) * fator);
         vwapBandmais1[i] = vwap + ((1 + offset) * fator);

         vwapBandmenos24[i] = vwap - ((24 + offset) * fator);
         vwapBandmenos23[i] = vwap - ((23 + offset) * fator);
         vwapBandmenos22[i] = vwap - ((22 + offset) * fator);
         vwapBandmenos21[i] = vwap - ((21 + offset) * fator);
         vwapBandmenos20[i] = vwap - ((20 + offset) * fator);
         vwapBandmenos19[i] = vwap - ((19 + offset) * fator);
         vwapBandmenos18[i] = vwap - ((18 + offset) * fator);
         vwapBandmenos17[i] = vwap - ((17 + offset) * fator);
         vwapBandmenos16[i] = vwap - ((16 + offset) * fator);
         vwapBandmenos15[i] = vwap - ((15 + offset) * fator);
         vwapBandmenos14[i] = vwap - ((14 + offset) * fator);
         vwapBandmenos13[i] = vwap - ((13 + offset) * fator);
         vwapBandmenos12[i] = vwap - ((12 + offset) * fator);
         vwapBandmenos11[i] = vwap - ((11 + offset) * fator);
         vwapBandmenos10[i] = vwap - ((10 + offset) * fator);
         vwapBandmenos9[i] = vwap - ((9 + offset) * fator);
         vwapBandmenos8[i] = vwap - ((8 + offset) * fator);
         vwapBandmenos7[i] = vwap - ((7 + offset) * fator);
         vwapBandmenos6[i] = vwap - ((6 + offset) * fator);
         vwapBandmenos5[i] = vwap - ((5 + offset) * fator);
         vwapBandmenos4[i] = vwap - ((4 + offset) * fator);
         vwapBandmenos3[i] = vwap - ((3 + offset) * fator);
         vwapBandmenos2[i] = vwap - ((2 + offset) * fator);
         vwapBandmenos1[i] = vwap - ((1 + offset) * fator);
      }
   } else if (input_mode == Percent){
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         vwap = vwapBuffer[i];

         vwapBandmais24[i] = vwap + (((24 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais23[i] = vwap + (((23 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais22[i] = vwap + (((22 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais21[i] = vwap + (((21 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais20[i] = vwap + (((20 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais19[i] = vwap + (((19 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais18[i] = vwap + (((18 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais17[i] = vwap + (((17 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais16[i] = vwap + (((16 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais15[i] = vwap + (((15 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais14[i] = vwap + (((14 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais13[i] = vwap + (((13 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais12[i] = vwap + (((12 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais11[i] = vwap + (((11 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais10[i] = vwap + (((10 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais9[i] = vwap + (((9 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais8[i] = vwap + (((8 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais7[i] = vwap + (((7 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais6[i] = vwap + (((6 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais5[i] = vwap + (((5 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais4[i] = vwap + (((4 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais3[i] = vwap + (((3 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais2[i] = vwap + (((2 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmais1[i] = vwap + (((1 + offset) * tamanho_banda_calculada) * vwap);

         vwapBandmenos24[i] = vwap - (((24 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos23[i] = vwap - (((23 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos22[i] = vwap - (((22 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos21[i] = vwap - (((21 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos20[i] = vwap - (((20 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos19[i] = vwap - (((19 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos18[i] = vwap - (((18 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos17[i] = vwap - (((17 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos16[i] = vwap - (((16 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos15[i] = vwap - (((15 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos14[i] = vwap - (((14 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos13[i] = vwap - (((13 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos12[i] = vwap - (((12 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos11[i] = vwap - (((11 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos10[i] = vwap - (((10 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos9[i] = vwap - (((9 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos8[i] = vwap - (((8 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos7[i] = vwap - (((7 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos6[i] = vwap - (((6 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos5[i] = vwap - (((5 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos4[i] = vwap - (((4 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos3[i] = vwap - (((3 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos2[i] = vwap - (((2 + offset) * tamanho_banda_calculada) * vwap);
         vwapBandmenos1[i] = vwap - (((1 + offset) * tamanho_banda_calculada) * vwap);
      }
   } else if (input_mode == Stdev) {
      for(int i = startVWAP - 1 ; i >= 0; i--) {
         vwap = vwapBuffer[i];

         vwapBandmais24[i] = vwap + (((24 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais23[i] = vwap + (((23 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais22[i] = vwap + (((22 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais21[i] = vwap + (((21 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais20[i] = vwap + (((20 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais19[i] = vwap + (((19 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais18[i] = vwap + (((18 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais17[i] = vwap + (((17 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais16[i] = vwap + (((16 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais15[i] = vwap + (((15 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais14[i] = vwap + (((14 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais13[i] = vwap + (((13 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais12[i] = vwap + (((12 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais11[i] = vwap + (((11 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais10[i] = vwap + (((10 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais9[i] = vwap + (((9 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais8[i] = vwap + (((8 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais7[i] = vwap + (((7 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais6[i] = vwap + (((6 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais5[i] = vwap + (((5 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais4[i] = vwap + (((4 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais3[i] = vwap + (((3 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais2[i] = vwap + (((2 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmais1[i] = vwap + (((1 + offset) * tamanho_banda_calculada) * stdev);

         vwapBandmenos24[i] = vwap - (((24 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos23[i] = vwap - (((23 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos22[i] = vwap - (((22 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos21[i] = vwap - (((21 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos20[i] = vwap - (((20 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos19[i] = vwap - (((19 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos18[i] = vwap - (((18 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos17[i] = vwap - (((17 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos16[i] = vwap - (((16 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos15[i] = vwap - (((15 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos14[i] = vwap - (((14 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos13[i] = vwap - (((13 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos12[i] = vwap - (((12 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos11[i] = vwap - (((11 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos10[i] = vwap - (((10 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos9[i] = vwap - (((9 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos8[i] = vwap - (((8 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos7[i] = vwap - (((7 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos6[i] = vwap - (((6 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos5[i] = vwap - (((5 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos4[i] = vwap - (((4 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos3[i] = vwap - (((3 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos2[i] = vwap - (((2 + offset) * tamanho_banda_calculada) * stdev);
         vwapBandmenos1[i] = vwap - (((1 + offset) * tamanho_banda_calculada) * stdev);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObject() {

   barras_visiveis = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);

   int      offset = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - barras_visiveis / 2;
   Hposition = iTime(_Symbol, PERIOD_CURRENT, offset);
   Vposition;

   if(Anchor == ANCHOR_TOP)
      Vposition = iLow(_Symbol, PERIOD_CURRENT, barras_visiveis - offset);
   else
      Vposition = iHigh(_Symbol, PERIOD_CURRENT, barras_visiveis - offset);

   ObjectCreate(0, prefix, OBJ_ARROW, 0, Hposition, Vposition);
   ObjectSetInteger(0, prefix, OBJPROP_COLOR, vwapColor);
//--- Código Wingdings
   ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 233);
//--- definir o estilo da linha da borda
   ObjectSetInteger(0, prefix, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, prefix, OBJPROP_FILL, false);
//--- exibir em primeiro plano (false) ou fundo (true)
   ObjectSetInteger(0, prefix, OBJPROP_BACK, false);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção
//--- é verdade por padrão, tornando possível destacar e mover o objeto
   ObjectSetInteger(0, prefix, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, prefix, OBJPROP_SELECTED, true);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
   ObjectSetInteger(0, prefix, OBJPROP_HIDDEN, false);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico
   ObjectSetInteger(0, prefix, OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, prefix, OBJPROP_FILL, true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomizeObject() {

   int posicao = iBarShift2(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix, OBJPROP_TIME));

   Hposition = iTime(_Symbol, PERIOD_CURRENT, posicao);
   if(Anchor == ANCHOR_TOP)
      Vposition = iLow(_Symbol, PERIOD_CURRENT, posicao);
   else
      Vposition = iHigh(_Symbol, PERIOD_CURRENT, posicao);

   ObjectMove(0, prefix, 0, Hposition, Vposition);

//--- Tamanho do objeto
   ObjectSetInteger(0, prefix, OBJPROP_WIDTH, arrowSize);
//--- Cor
   ObjectSetInteger(0, prefix, OBJPROP_COLOR, vwapColor);
//--- Código Wingdings
   if(Anchor == ANCHOR_TOP)
      ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 233);

   if(Anchor == ANCHOR_BOTTOM)
      ObjectSetInteger(0, prefix, OBJPROP_ARROWCODE, 234);

//--- Ponto de Ancoragem
   ObjectSetInteger(0, prefix, OBJPROP_ANCHOR, Anchor);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetObjectTime1(const string name) {
   datetime time;

   if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, time))
      return(0);

   return(time);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {
 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();

      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      Print("VWAP Bands " + vwapID + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}
bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStdDev(const double & arr[], int start, int end) {
   int size = MathAbs(start - end) + 1;
   if(size < 2)
      return(0.0);

   double sum = 0.0;
   for(int i = start; i >= end; i--) {
      sum = sum + arr[i];
   }

   sum = sum / size;

   double sum2 = 0.0;
   for(int i = start; i >= end; i--) {
      sum2 = sum2 + (arr[i] - sum) * (arr[i] - sum);
   }

   sum2 = sum2 / (size - 1);
   sum2 = MathSqrt(sum2);

   return(sum2);
}

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------+
