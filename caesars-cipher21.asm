subs        START       0 清除暫存器X的内容
            CLEAR       X 用stackinit的子程序，用於初始化堆疊
            JSUB        stackinit 用rdLine的子程序，用於讀取密文的第一行
            JSUB        rdLine
 
loop        JSUB        showLine 用showLine的子程序，顯示解密的部分，並等待使用者回應
read        JSUB        readKB 用readKB的子程序，讀取輸入
            COMP        #0
            JEQ         read 若讀取的值為0，則到read，繼續讀取輸入
            COMP        #89
            JEQ         cont 若讀取的值為89，則到cont，表示找到了正确的偏移量
            JSUB        printNL
            JSUB        clearKB
            TIX         #26
            JLT         loop 否則，印出一個換行符號，增加偏移量並重試。然後到loop處，繼續循環
cont        JSUB        printNL
            JSUB        rdLine 用rdLine的子程序，讀取下一行
            JSUB        showLine 用showLine的子程序，解密並顯示該行
            J           cont 跳到cont，繼續解密下一行
halt        J           halt
----------------------------------------------------------------------------------------------------------------------------------------------------------------
            STL         @stackptr 將暫存器 L 的值存入堆疊
            JSUB        stackpush 呼叫stackpush，將暫存器的值放入堆疊
            STX         @stackptr 將暫存器 X 的值存入堆疊
            JSUB        stackpush
            STS         @stackptr 將暫存器 S 的值存入堆疊
            JSUB        stackpush
            CLEAR       S 清除暫存器 S 的值
            ADDR        X,S 將暫存器 X 的值加上暫存器 S 的值，並將結果存入暫存器 S
            CLEAR       X
rc          CLEAR       A
            LDCH        line,X 從記憶體位置中根據暫存器 X 的內容載入一個字元放到暫存器 A 的低位元組
            COMP        #10
            JEQ         endSL  若A = 10，則跳到endSL的子程式結束 showLine
            JSUB        shift 呼叫shift的子程式，進行字元位移
            JSUB        printch 呼叫printch子程式，顯示位移後的字元
            TIX         #0
            J           rc 若X不等於 0，則跳回rc繼續讀取下一個字元
endSL       JSUB        stackpop 呼叫stackpop，將堆疊頂端的值彈出並存入相應的暫存器
            LDS         @stackptr 將堆疊頂端的值放入 S 暫存器
            JSUB        stackpop 呼叫stackpop
            LDX         @stackptr 將堆疊頂端的值放入 X 暫存器
            JSUB        stackpop 呼叫stackpop
            LDL         @stackptr 將堆疊頂端的值放入 L 暫存器
            RSUB
-------------------------------------------------------------------------------------------------------------------------------------------------------------
readKB      CLEAR       A  清除暫存器 A 的值
            LDCH        @keyboard 從鍵盤輸入中讀取一個字符，並將其存儲在 A 的最低位元組中
            RSUB
--------------------------------------------------------------------------------------------------------------------------------------------------------------
clearKB     CLEAR       A
            STCH        @keyboard 此指令將暫存器 A 的最低位元組的值存到 @keyboard 所指定的記憶體位置中
            RSUB
----------------------------------------------------------------------------------------------------------------------------------------------------------------
readch      TD          inputDev 測試輸入設備(inputDev）的結束條件
            JEQ         readch 若輸入設備已經結束，則跳回 readch，繼續等待輸入。
            CLEAR       A
            RD          inputDev 從inputDev讀取一個字符到暫存器 A
            . Test if EOF
            COMP        #0
            JEQ         halt A = 0，則跳到 halt，停止執行
            RSUB
------------------------------------------------------------------------------------------------------------------------------------------------------------
lower       COMP        #65
            JLT         noConv 如果字符小於A(65)，則跳到noConv，不進行轉換
            COMP        #90
            JGT         noConv 如果字符大於Z(90)，則跳到noConv，不進行轉換
            J           convLower 如果字符在A-Z，則跳到convLower執行轉換
noConv      RSUB 如果字符不在A-Z，則執行RSUB指令返回
convLower   ADD         #32 將字符的ASCII碼值增加32，轉換為小寫字母
            RSUB
----------------------------------------------------------------------------------------------------------------------------------------------------------------
shift       COMP        #65
            JLT         noShift 暫存器 A 的值若小於 65，則跳到 noShift，不進行位移
            COMP        #90
            JGT         shiftLower 暫存器 A 的值若大於 90，則跳到 shiftLower，對大寫字母進行位移
            SUBR        S,A 將暫存器 A 的值減去暫存器 S 的值，進行右移
            COMP        #65
            JLT         wrap 位移後的值若小於 65，則跳到 wrap，循環回到字母的末尾
shiftLower  COMP        #97
            JLT         noShift 暫存器 A 的值若小於 97(a)，則跳到 noShift，不進行位移
            COMP        #122
            JGT         noShift 暫存器 A 的值若大於 122(z)，則跳到 noShift，不進行位移
            SUBR        S,A 暫存器 A 的值減去暫存器 S 的值，進行右移
            COMP        #97
            JLT         wrap 位移後的值若小於 97(a)，則跳到 wrap，循環回到字母的末尾
noShift     RSUB 無移位指令，跳至下一行指令
wrap        ADD         #26 將下一個記憶體位置的值加26
            RSUB
---------------------------------------------------------------------------------------------------------------------------------------------------------          
stackpush   STA         subA 將暫存器A的值存入subA中
            LDA         stackptr 載入 stackptr 的值
            ADD         #3 將 stackptr 的值加 3
            STA         stackptr 將新的 stackptr 值存回記憶體
            LDA         subA 載入 subA 的值
            RSUB 返回指令
stackpop    STA         subA
            LDA         stackptr
            SUB         #3 將 stackptr 的值減去 3
            STA         stackptr
            LDA         subA
            RSUB
stackinit   STA         subA 將 subA 的值存到記憶體中
            LDA         #stack 將 stack 的位址載入暫存器
            STA         stackptr 將 stack 的位址存儲到 stackptr
            LDA         subA 載入 subA 的值
            RSUB
subA        RESW        1
----------------------------------------------------------------------------------------------------------------------------------------------------
rdLine      STL         @stackptr 將暫存器 L 的值存入堆疊
            JSUB        stackpush 呼叫stackpush，將暫存器的值放入堆疊
            STX         @stackptr 將暫存器 X 的值存入堆疊
            JSUB        stackpush 呼叫stackpush，將暫存器的值放入堆疊
            CLEAR       X
rdl         JSUB        readch 用readch子程序，從設備讀取一個字符
            STCH        line,X 將讀取的字符儲存到X
            TIX         #0 將X的值減1，並與0比較
            COMP        #10
            JEQ         endRL 若等於10（讀取的字符是換行符），則跳轉到endRL標籤處，從rdLine中返回
            J           rdl 其餘跳到rdl，繼續讀取字符
endRL       JSUB        stackpop 呼叫stackpop，將堆疊頂端的值彈出並存入相應的暫存器
            LDX         @stackptr 將堆疊中的值放入 X 暫存器
            JSUB        stackpop 呼叫 stackpop 
            LDL         @stackptr 將堆疊中的值存入 L 寄存器
            RSUB
------------------------------------------------------------------------------------------------------------------------------------------------------
printch     STL         @stackptr       將 printch 字元存入 @stackptr
            JSUB        stackpush       調用 stackpush 函數
            STS         @stackptr       將 STS 存入 @stackptr
            JSUB        stackpush       调用 stackpush 函数
            CLEAR       S               清除寄存器 S 的值
            ADDR        A,S             將寄存器 S 的值加到寄存器 A
            LDA         scrY            将 scrY 的值加载到寄存器 A
            MUL         #80             將寄存器 A 的值乘以 80
            ADD         screen          將 screen 的值加到寄存器 A
            ADD         scrX            将 scrX 的值加到寄存器 A
            STA         screenptr       將寄存器A的值存入screenptr
            CLEAR       A               清除寄存器 A 的值
            ADDR        S,A             将寄存器 A 的值加到寄存器 S
            STCH        @screenptr      将寄存器 A 中的字节存储到 @screenptr 的位置
            LDA         scrX            将 scrX 的值加载到寄存器 A
            ADD         #1              将寄存器 A 的值加上 1
            COMP        #80             将寄存器 A 的值与 80 进行比较
            JEQ         prNL            如果寄存器 A 的值等于 80，则跳转到标签 prNL
            STA         scrX            将寄存器 A 的值存储到 scrX
            J           exitprch        无条件跳转到标签 exitprch
prNL        JSUB        printNL         调用 printNL 函数，子程序标签为 prNL
exitprch    JSUB        stackpop        调用 stackpop 函数，子程序标签为 exitprch
            LDS         @stackptr       將 @stackptr 的值加載到 S 寄存器
            JSUB        stackpop        調用 stackpop 子程序
            LDL         @stackptr       將 @stackptr 的值加載到 L 寄存器
            RSUB 無條件返回主程序
-------------------------------------------------------------------------------------------------------------------------------------------------------
printNL     STL         @stackptr       將 printNL 存入 @stackptr
            JSUB        stackpush       調用 stackpush 函數
            STA         @stackptr       將 STA 存入 @stackptr
            JSUB        stackpush       调用 stackpush 函数
            LDA         scrY            将 scrY 的值加载到寄存器 A
            ADD         #1              将寄存器 A 的值加上 1
            COMP        #25             将寄存器 A 的值与 25 进行比较
            JEQ	        cls             如果寄存器 A 的值等于 25，则跳转到标签 cls
            J           clsSkip         无条件跳转到标签 clsSkip
cls         JSUB        clearScreen     调用 clearScreen 函数，子程序标签为 cls
clsSkip     STA         scrY            将寄存器 A 的值存储到 scrY
            CLEAR       A               清除寄存器 A 的值
            STA         scrX            将寄存器 A 的值存储到 scrX
            JSUB        stackpop        调用 stackpop 函数
            LDA         @stackptr       将 @stackptr 的值加载到寄存器 A
            JSUB        stackpop        调用 stackpop 函数
            LDL         @stackptr       将 @stackptr 的值加载到寄存器 L
            RSUB                        无条件返回主程序
clearScreen STL         @stackptr       将 clearScreen 存入 @stackptr
            JSUB        stackpush       调用 stackpush 函数
            STX         @stackptr       将寄存器 X 的值存入 @stackptr
            JSUB        stackpush       调用 stackpush 函数
            CLEAR       A               清除寄存器 A 的值
            STA         scrY            将寄存器 A 的值存储到 scrY
            STA         scrX            将寄存器 A 的值存储到 scrX
            CLEAR       X               清除寄存器 X 的值
contClear   CLEAR       A               清除寄存器 A 的值
            JSUB        printch         调用 printch 函数
            TIX         #1999           将寄存器 X 的值与 1999 进行比较
            JEQ         endClear        如果寄存器 X 的值等于 1999，则跳转到标签 endClear
            J	        contClear       无条件跳转到标签 contClear
endClear    LDA         screenptr       将 screenptr 的值加载到寄存器 A
            ADD         #1              將寄存器 A 的值加上 1
            STA         screenptr       將寄存器 A 的值存入 screenptr
            CLEAR       A               清除寄存器 A 的值
            STCH        @screenptr      將寄存器 A 中的字節存儲到 @screenptr 的位置
            CLEAR       A               清除寄存器 A 的值
            STA         scrX            將寄存器 A 的值存儲到 scrX
            STA         scrY            将寄存器 A 的值存储到 scrY
            JSUB        stackpop        調用 stackpop 子程序
            LDX         @stackptr       將 @stackptr 的值加載到 X 寄存器
            JSUB        stackpop        调用 stackpop 函数
            LDL         @stackptr       将 @stackptr 的值加载到寄存器 L
            RSUB                        无条件返回主程序
------------------------------------------------------------------------------------------------------------------------------------------------------------
inputDev    BYTE        X'AA'           將十六進制值 AA 存儲到 inputDev
screen      WORD        0x0B800         將十六進制值 0B800 存儲到 screen
screenptr   RESW        1               保留一個字的空間給 screenptr
scrX        WORD        0               將值 0 存儲到 scrX
scrY        WORD        0               將值 0 存儲到 scrY
keyboard    WORD        0xC000          將十六進制值 C000 存儲到 keyboard
line        RESB        1024            保留 1024 個字節的空間給 line
stackptr    RESW        1               保留一个字的空间给 stackptr
stack       RESW        1024            保留 1024 个字的空间给 stack