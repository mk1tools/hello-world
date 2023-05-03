      * REPERIMENTO CHIAMANTE
      *
      * PARAMETRI
      * calllib 10 A libreria del programma chiamante
      * callpgm 10 A nome del programma chiamante
      *
     h indent(' ')
     h option(*nodebugio: *srcstmt)

      * prototipo API
     D RtvStack        pr                  extpgm('QWVRCSTK')
     D  RecVar                     2000a
     D  LenghtRecVar                 10i 0
     D  FmtRecVar                     8a   const
     D  JobIDInf                     56a
     D  FmtJobID                      8a   const
     D  Error                        15a

      * status program DS (nome programma corrente)
     D psds           sds
     D  program          *proc

      * parametri
     DCallLib          s             10
     DCallPgm          s             10
      *--------------------------------------------------------------------*
     d idx             s              5i 0

      * DS mappatura 1º parametro API: RecVar (formato CSTK0100)
      *  per programmi OPM o ILE
     d RecVar          ds          2000
      *  Bytes returned
     d  BytRtn                       10i 0
      *  Bytes available
     d  BytAvl                       10i 0
      *  Number of call stack entries for thread
     d  Entries                      10i 0
      *  Offset to call stack entry information
     d  Offset                       10i 0
      *  Number of call stack entries returned
     d  EntryCount                   10i 0
      *  Returned Thread identifier
     d  ThreadID                      8a
      *  Information status (' ' no error, I = information not complete, N = no entries returned)
     d  InfStatus                     1a

      * 2º parametro API: lunghezza del 1º restituito da API
     d VarLen          s             10i 0 inz(%size(RecVar))

      * DS mappatura 4º parametro: job di cui reperire lo stack (corrente) formato JIDF0100
     d JobIDInf        ds
      * Job name (10) + User name (10) + job number (6)
      *  '*' = the job ib which this program is running
     d  JIDQName                     26    inz('*')
      *  Internal job identifier
     d  JIDIntID                     16
      *  reserved
     d  JIDRes3                       2    inz(*loval)
      *  Thread indicator
     d  JIDThreadInd                 10i 0 inz(1)
      *  Thread identifier
     d  JIDThread                     8    inz(*loval)

      * 6º parametro API: info errore API
     d ApiErr          s             15

      * DS mappatura singola voce dello stack restituita da API
     d Entry           ds           256    inz
      *  Length of this call stack entry
     d  EntryLen                     10i 0
      *  Request level
     d  ResqtLvl                     10i 0 overlay(Entry:21)
      *  Program name
     d  PgmNam                       10    overlay(Entry:25)
      *  Program library
     d  PgmLib                       10    overlay(Entry:35)
      *  Module name
     d  ModName                      10    overlay(Entry:49)
      *  Module library
     d  ModLib                       10    overlay(Entry:59)
      *  Control boundary (0 = no control boundary is active, 1 = control boundary active)
     d  CtlBnd                        1    overlay(Entry:69)
      *  Activation group name
     d  ActGrpNam                    10    overlay(Entry:77)

     C     *entry        plist
     C                   parm                    CallLib
     C                   parm                    CallPgm

      /free
       // richiamo API per stack chiamate
       callp(e) RtvStack(RecVar :
                         Varlen :
                         'CSTK0100' :
                         JobIDInf :
                         'JIDF0100' :
                         ApiErr);
       // ciclo sullo stack, restituisco il primo programma non di sistema
       // quindi diverso da Q* e diverso dall'attuale programma
       for idx = 1 to Entries;
         Entry = %subst(RecVar:Offset + 1);
         Offset = Offset + EntryLen;
         if %subst(PgmNam: 1: 1) = 'Q';
           iter;
         endif;
         if PgmNam = Program;
           iter;
         endif;
         CallLib = PgmLib;
         CallPgm = PgmNam;
         leave;
       endfor;

       *inlr = *on;
      /end-free
