; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

; OSS-Fuzz: https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=5223
define void @test_bigalloc(i8** %dst) {
; CHECK-LABEL: @test_bigalloc(
; CHECK-NEXT:    [[TMP1:%.*]] = alloca [18446744069414584320 x i8], align 1
; CHECK-NEXT:    [[DOTSUB:%.*]] = getelementptr inbounds [18446744069414584320 x i8], [18446744069414584320 x i8]* [[TMP1]], i64 0, i64 0
; CHECK-NEXT:    store i8* [[DOTSUB]], i8** [[DST:%.*]], align 8
; CHECK-NEXT:    ret void
;
  %1 = alloca i8, i864 -4294967296
  %2 = getelementptr i8, i8* %1, i1 0
  store i8* %2, i8** %dst
  ret void
}