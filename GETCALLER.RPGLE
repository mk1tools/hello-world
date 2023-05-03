000100091019      * REPERIMENTO CHIAMANTE
000200091016      *
000300091019      * PARAMETRI
000400130513      * calllib 10 A libreria del programma chiamante
000500130513      * callpgm 10 A nome del programma chiamante
000600091019      *
000700130513     h indent(' ')
000800130513     h option(*nodebugio: *srcstmt)
000900130513
001000130513      * prototipo API
001100130513     D RtvStack        pr                  extpgm('QWVRCSTK')
001200130513     D  RecVar                     2000a
001300130513     D  LenghtRecVar                 10i 0
001400130513     D  FmtRecVar                     8a   const
001500130513     D  JobIDInf                     56a
001600130513     D  FmtJobID                      8a   const
001700130513     D  Error                        15a
001800130513
001900091019      * status program DS (nome programma corrente)
002000090828     D psds           sds
002100130513     D  program          *proc
002200130513
002300091019      * parametri
002400130513     DCallLib          s             10
002500130513     DCallPgm          s             10
002600091019      *--------------------------------------------------------------------*
002700090828     d idx             s              5i 0
002800130513
002900130513      * DS mappatura 1º parametro API: RecVar (formato CSTK0100)
003000130513      *  per programmi OPM o ILE
003100130513     d RecVar          ds          2000
003200130513      *  Bytes returned
003300130513     d  BytRtn                       10i 0
003400130513      *  Bytes available
003500130513     d  BytAvl                       10i 0
003600130513      *  Number of call stack entries for thread
003700130513     d  Entries                      10i 0
003800130513      *  Offset to call stack entry information
003900130513     d  Offset                       10i 0
004000130513      *  Number of call stack entries returned
004100130513     d  EntryCount                   10i 0
004200130513      *  Returned Thread identifier
004300130513     d  ThreadID                      8a
004400130513      *  Information status (' ' no error, I = information not complete, N = no entries returned)
004500130513     d  InfStatus                     1a
004600130513
004700130513      * 2º parametro API: lunghezza del 1º restituito da API
004800130513     d VarLen          s             10i 0 inz(%size(RecVar))
004900130513
005000130513      * DS mappatura 4º parametro: job di cui reperire lo stack (corrente) formato JIDF0100
005100130513     d JobIDInf        ds
005200130513      * Job name (10) + User name (10) + job number (6)
005300130513      *  '*' = the job ib which this program is running
005400130513     d  JIDQName                     26    inz('*')
005500130513      *  Internal job identifier
005600130513     d  JIDIntID                     16
005700130513      *  reserved
005800130513     d  JIDRes3                       2    inz(*loval)
005900130513      *  Thread indicator
006000130513     d  JIDThreadInd                 10i 0 inz(1)
006100130513      *  Thread identifier
006200130513     d  JIDThread                     8    inz(*loval)
006300130513
006400130513      * 6º parametro API: info errore API
006500130513     d ApiErr          s             15
006600130513
006700130513      * DS mappatura singola voce dello stack restituita da API
006800130513     d Entry           ds           256    inz
006900130513      *  Length of this call stack entry
007000130513     d  EntryLen                     10i 0
007100130513      *  Request level
007200130513     d  ResqtLvl                     10i 0 overlay(Entry:21)
007300130513      *  Program name
007400130513     d  PgmNam                       10    overlay(Entry:25)
007500130513      *  Program library
007600130513     d  PgmLib                       10    overlay(Entry:35)
007700130513      *  Module name
007800130513     d  ModName                      10    overlay(Entry:49)
007900130513      *  Module library
008000130513     d  ModLib                       10    overlay(Entry:59)
008100130513      *  Control boundary (0 = no control boundary is active, 1 = control boundary active)
008200130513     d  CtlBnd                        1    overlay(Entry:69)
008300130513      *  Activation group name
008400130513     d  ActGrpNam                    10    overlay(Entry:77)
008500130513
008600091019     C     *entry        plist
008700130513     C                   parm                    CallLib
008800130513     C                   parm                    CallPgm
008900130513
009000130513      /free
009100130513       // richiamo API per stack chiamate
009200130513       callp(e) RtvStack(RecVar :
009300130513                         Varlen :
009400130513                         'CSTK0100' :
009500130513                         JobIDInf :
009600130513                         'JIDF0100' :
009700130513                         ApiErr);
009800130513       // ciclo sullo stack, restituisco il primo programma non di sistema
009900130513       // quindi diverso da Q* e diverso dall'attuale programma
010000130513       for idx = 1 to Entries;
010100130513         Entry = %subst(RecVar:Offset + 1);
010200130513         Offset = Offset + EntryLen;
010300130513         if %subst(PgmNam: 1: 1) = 'Q';
010400130513           iter;
010500130513         endif;
010600130513         if PgmNam = Program;
010700130513           iter;
010800130513         endif;
010900130513         CallLib = PgmLib;
011000130513         CallPgm = PgmNam;
011100130513         leave;
011200130513       endfor;
011300130513
011400130513       *inlr = *on;
011500130513      /end-free
