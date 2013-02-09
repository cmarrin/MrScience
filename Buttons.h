//
//  Buttons.h
//  MrScience
//
//  Created by Chris Marrin on 6/21/11.
//  Copyright 2011 Chris Marrin. All rights reserved.
//

#ifndef MrScience_Buttons_h
#define MrScience_Buttons_h

#define buttonSqrtX         101
#define buttonEToTheX       102
#define buttonLN            103
#define buttonYToTheX       104
#define buttonOneOverX      105
#define buttonSummation     106
#define buttonRollDown      107
#define buttonSto           108
#define buttonRcl           109
#define buttonSin           110
#define buttonCos           111
#define buttonTan           112

#define buttonEnter         120
#define buttonExch          121

#define buttonChangeSign    122
#define buttonExponent      123
#define buttonBackspace     124

#define button0             130
#define button1             131
#define button2             132
#define button3             133
#define button4             134
#define button5             135
#define button6             136
#define button7             137
#define button8             138
#define button9             139
#define buttonDecimal       140

#define button2nd           141
#define buttonFUN           142
#define buttonPRG           143
#define buttonRS            144

#define buttonDivide        150
#define buttonMuliply       151
#define buttonSubtract      152
#define buttonAdd           153
#define buttonC             154

#define buttonXSquared      211
#define button10ToTheX      212
#define buttonLOG           213
#define buttonXRootOfY      214
#define buttonXFactorial    215
#define buttonSummationMinus 216
#define buttonRollUp        221
#define buttonPI            222
#define buttonHYP           223
#define buttonASin          224
#define buttonACos          225
#define buttonATan          226
#define buttonLastX         231
#define buttonPercent       232
#define buttonDeltaPercent  233
#define button2ToTheX       234
#define buttonLOG2          235
#define button2ndBack       241
#define buttonDispALL       242
#define buttonBaseDEC       243
#define buttonClearVARS     244
#define buttonRound         245

#define buttonModeDEG       251
#define buttonDispFIX       252
#define buttonBaseHEX       253
#define buttonClearPGM      254
#define buttonTrunc         255
#define buttonModeRAD       261
#define buttonDispSCI       262
#define buttonBaseBIN       263
#define buttonClearSUM      264
#define buttonFrac          265
#define buttonModeGRAD      271
#define buttonDispENG       272
#define buttonBaseOCT       273
#define buttonClearSTACK    274
#define buttonAbs           275

#define buttonPrecision0    372
#define buttonPrecision1    362
#define buttonPrecision2    363
#define buttonPrecision3    364
#define buttonPrecision4    352
#define buttonPrecision5    353
#define buttonPrecision6    354
#define buttonPrecision7    342
#define buttonPrecision8    343
#define buttonPrecision9    344
#define buttonPrecision10   332
#define buttonPrecision11   333
#define buttonPrecision12   334
#define buttonPrecisionCancel 374

#define buttonRegFirst      395
#define buttonRegBase       400 // Subtracted from tag to get index of button
#define buttonRegLast       431
#define buttonRegIndX       395
#define buttonRegIndIPreDec 396
#define buttonRegIndIPostInc 397
#define buttonRegIndI       398
#define buttonRegIndex      399
#define buttonRegDivide     490
#define buttonRegMultiply   491
#define buttonRegSubtract   492
#define buttonRegAdd        493
#define buttonRegCancel     499

#define buttonHexA          501
#define buttonHexB          502
#define buttonHexC          503
#define buttonHexD          504
#define buttonHexE          505
#define buttonHexF          506

#define buttonHexAND        510
#define buttonHexOR         511
#define buttonHexXOR        512
#define buttonHexNEG        513
#define buttonHexNOT        514
#define buttonHexSHL        824
#define buttonHexSHR        825
#define buttonHexMOD        826

#define buttonFUNXMean      901
#define buttonFUNXWMean     902
#define buttonFUNPSDX       903
#define buttonFUNPSDY       904
#define buttonFUNSSDX       905
#define buttonFUNSSDY       906
#define buttonFUNYMean      907
#define buttonFUNCnr        908
#define buttonFUNPnr        909
#define buttonFUNRand       910
#define buttonFUNSeed       911

#define buttonFUNDup2       920
#define buttonFUNOver       921
#define buttonFUNSolve      922

#define buttonFUNShowInfo   930
#define buttonFUNUser1      931
#define buttonFUNUser2      932
#define buttonFUNUser3      933
#define buttonFUNUser4      934
#define buttonFUNUser5      935
#define buttonFUNUser6      936
#define buttonFUNUser7      937
#define buttonFUNUser8      938
#define buttonFUNUser9      939

#define buttonFUNName       942
#define buttonFUNLoad       943

#define buttonFUNBack       951
#define buttonFUNCNV        952

#define buttonCNVConvert    1001
#define buttonCNVBack       1061
#define buttonCNVToDegC     1062
#define buttonCNVToDegF     1063
#define buttonCNVToRad      1064
#define buttonCNVToDeg      1065
#define buttonCNVToHMS      1072
#define buttonCNVToH        1073
#define buttonCNVToPolar    1074
#define buttonCNVToRect     1075

#define buttonPRGIf         1200
#define buttonPRGElse       1201
#define buttonPRGThen       1202
#define buttonPRGEQ         1203
#define buttonPRGNE         1204
#define buttonPRGLT         1205
#define buttonPRGGT         1206
#define buttonPRGLE         1207
#define buttonPRGGE         1208
#define buttonPRGFor        1210
#define buttonPRGDo         1211
#define buttonPRGBreak      1212
#define buttonPRGBreakIf    1213
#define buttonPRGLoop       1214
#define buttonPRGCall       1220
#define buttonPRGRet        1221
#define buttonPRGRetIf      1222
#define buttonPRGInput      1230
#define buttonPRGPause      1231
#define buttonPRGFunc       1240
#define buttonPRGSubr       1241
#define buttonPRGNew        1242
#define buttonPRGDelFunc    1243
#define buttonPRGADD        1251
#define buttonPRGSTEP       1252
#define buttonPRGQUIT       1253
#define buttonPRGDEL        1254
#define buttonPRGBack       1290

// Alphanumeric keys have tags which are their ASCII value plus 'buttonAlphaNumericOffset'
// Several characters are special and are represented by lower-case ASCII letters, but 
// their letterforms are different.
#define buttonAlphanumericOffset    11000



#endif
