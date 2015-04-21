; RUN: opt -S %loadPolly -polly-detect-unprofitable -polly-dependences -analyze < %s | FileCheck %s -check-prefix=VALUE
; RUN: opt -S %loadPolly -polly-detect-unprofitable -polly-dependences -analyze -polly-dependences-computeout=1 < %s | FileCheck %s -check-prefix=TIMEOUT
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-pc-linux-gnu"

;     for(i = 0; i < 100; i++ )
; S1:   A[i] = 2;
;
;     for (i = 0; i < 10; i++ )
; S2:   A[i]  = 5;
;
;     for (i = 0; i < 200; i++ )
; S3:   A[i] = 5;

define void @sequential_writes() {
entry:
  %A = alloca [200 x i32]
  br label %S1

S1:
  %indvar.1 = phi i64 [ 0, %entry ], [ %indvar.next.1, %S1 ]
  %arrayidx.1 = getelementptr [200 x i32], [200 x i32]* %A, i64 0, i64 %indvar.1
  store i32 2, i32* %arrayidx.1
  %indvar.next.1 = add i64 %indvar.1, 1
  %exitcond.1 = icmp ne i64 %indvar.next.1, 100
  br i1 %exitcond.1, label %S1, label %exit.1

exit.1:
  br label %S2

S2:
  %indvar.2 = phi i64 [ 0, %exit.1 ], [ %indvar.next.2, %S2 ]
  %arrayidx.2 = getelementptr [200 x i32], [200 x i32]* %A, i64 0, i64 %indvar.2
  store i32 5, i32* %arrayidx.2
  %indvar.next.2 = add i64 %indvar.2, 1
  %exitcond.2 = icmp ne i64 %indvar.next.2, 10
  br i1 %exitcond.2, label %S2, label %exit.2

exit.2:
  br label %S3

S3:
  %indvar.3 = phi i64 [ 0, %exit.2 ], [ %indvar.next.3, %S3 ]
  %arrayidx.3 = getelementptr [200 x i32], [200 x i32]* %A, i64 0, i64 %indvar.3
  store i32 7, i32* %arrayidx.3
  %indvar.next.3 = add i64 %indvar.3, 1
  %exitcond.3 = icmp ne i64 %indvar.next.3, 200
  br i1 %exitcond.3, label %S3 , label %exit.3

exit.3:
  ret void
}

; VALUE: region: 'S1 => exit.3' in function 'sequential_writes':
; VALUE:   RAW dependences:
; VALUE:     {  }
; VALUE:   WAR dependences:
; VALUE:     {  }
; VALUE:   WAW dependences:
; VALUE:     {
; VALUE:       Stmt_S1[i0] -> Stmt_S2[i0] : i0 >= 0 and i0 <= 9;
; VALUE:       Stmt_S2[i0] -> Stmt_S3[i0] : i0 >= 0 and i0 <= 9;
; VALUE:       Stmt_S1[i0] -> Stmt_S3[i0] : i0 >= 10 and i0 <= 99
; VALUE:     }

; TIMEOUT: region: 'S1 => exit.3' in function 'sequential_writes':
; TIMEOUT:   RAW dependences:
; TIMEOUT:     n/a
; TIMEOUT:   WAR dependences:
; TIMEOUT:     n/a
; TIMEOUT:   WAW dependences:
; TIMEOUT:     n/a
