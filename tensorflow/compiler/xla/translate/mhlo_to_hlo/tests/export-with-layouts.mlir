// RUN: xla-translate -split-input-file -mlir-hlo-to-hlo-text -with-layouts -print-layouts %s | FileCheck %s
// RUN: xla-translate -split-input-file -mlir-hlo-to-hlo-text  -with-layouts -print-layouts --via-builder=true %s | FileCheck %s

#CSR = #sparse_tensor.encoding<{
  dimLevelType = ["dense", "compressed"],
  dimOrdering = affine_map<(i, j) -> (i, j)>,
  pointerBitWidth = 32,
  indexBitWidth = 32
}>

// CHECK:  HloModule
func.func @main(%arg: tensor<3x4xf32, #CSR>) -> tensor<3x4xf32, #CSR> {
  // CHECK: ROOT %[[ARG0:.*]] = f32[3,4]{1,0:D(D,C)} parameter(0)
  return %arg : tensor<3x4xf32, #CSR>
}

// -----

#COO = #sparse_tensor.encoding<{
  dimLevelType = ["compressed", "singleton"],
  dimOrdering = affine_map<(i, j) -> (i, j)>,
  pointerBitWidth = 32,
  indexBitWidth = 32
}>

// CHECK:  HloModule
func.func @main(%arg: tensor<3x4xf32, #COO>) -> tensor<3x4xf32, #COO> {
  // CHECK: ROOT %[[ARG0:.*]] = f32[3,4]{1,0:D(C,S)} parameter(0)
  return %arg : tensor<3x4xf32, #COO>
}
