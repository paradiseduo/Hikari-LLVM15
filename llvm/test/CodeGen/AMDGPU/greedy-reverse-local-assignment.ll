; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdhsa -greedy-reverse-local-assignment=0 -mcpu=gfx900 < %s | FileCheck -check-prefixes=FORWARDXNACK %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -greedy-reverse-local-assignment=1 -mcpu=gfx900 < %s | FileCheck -check-prefixes=REVERSEXNACK %s

; RUN: llc -mtriple=amdgcn-amd-amdhsa -greedy-reverse-local-assignment=0 -mcpu=gfx900 -mattr=-xnack < %s | FileCheck -check-prefix=NOXNACK %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -greedy-reverse-local-assignment=1 -mcpu=gfx900 -mattr=-xnack < %s | FileCheck -check-prefix=NOXNACK %s

; Test the change in the behavior of the allocator with
; -greedy-reverse-local-reassignment enabled. This case shows a
; regression with it enabled if xnack is enabled.

; The outgoing return physical register copies strongly hint the
; output registers to use for the load return values, and end up
; taking precedence over the copies from the incoming values with
; reverse order. With the kills inserted to artifically extend the
; pointer live ranges to hint the soft clause, we get worse
; allocation and need the extra copies before the loads.
define <4 x half> @shuffle_v4f16_234u(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; FORWARDXNACK-LABEL: shuffle_v4f16_234u:
; FORWARDXNACK:       ; %bb.0:
; FORWARDXNACK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FORWARDXNACK-NEXT:    global_load_dword v6, v[0:1], off offset:4
; FORWARDXNACK-NEXT:    global_load_dwordx2 v[4:5], v[2:3], off
; FORWARDXNACK-NEXT:    s_waitcnt vmcnt(1)
; FORWARDXNACK-NEXT:    v_mov_b32_e32 v0, v6
; FORWARDXNACK-NEXT:    s_waitcnt vmcnt(0)
; FORWARDXNACK-NEXT:    v_mov_b32_e32 v1, v4
; FORWARDXNACK-NEXT:    s_setpc_b64 s[30:31]
;
; REVERSEXNACK-LABEL: shuffle_v4f16_234u:
; REVERSEXNACK:       ; %bb.0:
; REVERSEXNACK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; REVERSEXNACK-NEXT:    v_mov_b32_e32 v6, v1
; REVERSEXNACK-NEXT:    v_mov_b32_e32 v5, v0
; REVERSEXNACK-NEXT:    v_mov_b32_e32 v4, v3
; REVERSEXNACK-NEXT:    v_mov_b32_e32 v3, v2
; REVERSEXNACK-NEXT:    global_load_dword v0, v[5:6], off offset:4
; REVERSEXNACK-NEXT:    global_load_dwordx2 v[1:2], v[3:4], off
; REVERSEXNACK-NEXT:    s_waitcnt vmcnt(0)
; REVERSEXNACK-NEXT:    s_setpc_b64 s[30:31]
;
; NOXNACK-LABEL: shuffle_v4f16_234u:
; NOXNACK:       ; %bb.0:
; NOXNACK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOXNACK-NEXT:    global_load_dword v0, v[0:1], off offset:4
; NOXNACK-NEXT:    global_load_dwordx2 v[1:2], v[2:3], off
; NOXNACK-NEXT:    s_waitcnt vmcnt(0)
; NOXNACK-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 4, i32 undef>
  ret <4 x half> %shuffle
}