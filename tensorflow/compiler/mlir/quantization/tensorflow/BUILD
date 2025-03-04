load("//tensorflow:tensorflow.bzl", "tf_cc_binary")
load("//tensorflow:tensorflow.default.bzl", "get_compatible_with_cloud")
load("//tensorflow/core/platform:build_config.bzl", "tf_proto_library")
load("//tensorflow/compiler/mlir/quantization/tensorflow:internal_visibility_allowlist.bzl", "internal_visibility_allowlist")
load("@llvm-project//mlir:tblgen.bzl", "gentbl_cc_library", "td_library")
load("//tensorflow/core/platform:build_config_root.bzl", "if_static")

# TODO(b/249181641): Restructure source codes for TF quantization.
package_group(
    name = "internal_visibility_allowlist_package",
    packages = [
        "//tensorflow/compiler/mlir/quantization/...",
        "//tensorflow/compiler/mlir/lite/...",
        "//third_party/cloud_tpu/inference_converter/...",  # TPU Inference Converter V1
    ] + internal_visibility_allowlist(),
)

package(
    default_visibility = [
        ":internal_visibility_allowlist_package",
        "//tensorflow:__pkg__",
    ],
    licenses = ["notice"],
)

cc_library(
    name = "constants",
    hdrs = [
        "constants.h",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "@com_google_absl//absl/strings",
    ],
)

py_binary(
    name = "gen_quantized_function_library",
    srcs = ["gen_quantized_function_library.py"],
    deps = [
        "@absl_py//absl:app",
        "@absl_py//absl/flags",
    ],
)

genrule(
    name = "quantized_function_library",
    srcs = [
        "passes/quantized_function_library.mlir",
        "passes/quantized_function_library_uniform_quantized_drq.mlir",
        "passes/quantized_function_library_tf_drq.mlir",
    ],
    outs = [
        "passes/quantized_function_library.h",
    ],
    cmd = "$(location gen_quantized_function_library) --output_file $(RULEDIR)/passes/quantized_function_library.h --src '$(SRCS)'",
    compatible_with = get_compatible_with_cloud(),
    exec_tools = ["gen_quantized_function_library"],
)

cc_library(
    name = "pass_utils",
    srcs = [
        "passes/utils.cc",
    ],
    hdrs = [
        "passes/utils.h",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "//tensorflow/compiler/mlir/lite/quantization:quantization_lib",
        "//tensorflow/compiler/mlir/quantization/tensorflow:quantization_options_proto_cc",
        "//tensorflow/compiler/mlir/tensorflow",
        "//tensorflow/compiler/mlir/tensorflow:eval_util",
        "@llvm-project//llvm:Support",
        "@llvm-project//mlir:IR",
    ],
)

td_library(
    name = "quant_td_files",
    srcs = [
        "passes/lift_quantizable_spots_as_functions.td",
        "passes/lift_quantizable_spots_as_functions_drq.td",
        "passes/optimize.td",
        "passes/post_quantize.td",
        "passes/prepare_lifting.td",
        "passes/prepare_quantize.td",
        "passes/quantize_composite_functions.td",
        "passes/replace_cast_hacks_with_tf_xla_ops.td",
        "passes/tf_quant_ops.td",
        "passes/utils.td",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "//tensorflow/compiler/mlir/lite:tensorflow_lite_ops_td_files",
        "//tensorflow/compiler/mlir/quantization/tensorflow/utils:lift_as_function_call_utils_td_files",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_ops_td_files",
        "@llvm-project//mlir:ArithOpsTdFiles",
        "@llvm-project//mlir:FuncTdFiles",
    ],
)

gentbl_cc_library(
    name = "prepare_lifting_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/prepare_lifting.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/prepare_lifting.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "lift_quantizable_spots_as_functions_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/lift_quantizable_spots_as_functions.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/lift_quantizable_spots_as_functions.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "lift_quantizable_spots_as_functions_drq_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/lift_quantizable_spots_as_functions_drq.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/lift_quantizable_spots_as_functions_drq.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "prepare_quantize_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/prepare_quantize.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/prepare_quantize.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "quantize_composite_functions_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/quantize_composite_functions.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/quantize_composite_functions.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "tf_quant_ops_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-op-decls"],
            "passes/tf_quant_ops.h.inc",
        ),
        (
            ["-gen-op-defs"],
            "passes/tf_quant_ops.cc.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/tf_quant_ops.td",
    deps = [
        ":quant_td_files",
    ],
)

gentbl_cc_library(
    name = "optimize_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/optimize.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/optimize.td",
    deps = [":quant_td_files"],
)

gentbl_cc_library(
    name = "post_quantize_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/post_quantize.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/post_quantize.td",
    deps = [":quant_td_files"],
)

cc_library(
    name = "tf_quant_ops",
    srcs = [
        "passes/tf_quant_ops.cc",
        "passes/tf_quant_ops.cc.inc",
        "passes/tf_quant_ops.h.inc",
    ],
    hdrs = ["passes/tf_quant_ops.h"],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_attributes",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_op_interfaces",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_side_effects",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_structs",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_traits",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_types",
        "@llvm-project//llvm:Support",
        "@llvm-project//mlir:ControlFlowInterfaces",
        "@llvm-project//mlir:DerivedAttributeOpInterface",
        "@llvm-project//mlir:Dialect",
        "@llvm-project//mlir:FuncDialect",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:InferTypeOpInterface",
        "@llvm-project//mlir:LoopLikeInterface",
        "@llvm-project//mlir:Parser",
        "@llvm-project//mlir:SideEffectInterfaces",
        "@llvm-project//mlir:Support",
    ],
)

cc_library(
    name = "tf_op_quant_spec",
    srcs = [
        "ops/tf_op_quant_spec.cc",
    ],
    hdrs = ["ops/tf_op_quant_spec.h"],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "//tensorflow/compiler/mlir/lite/quantization:quantization_config",
        "//tensorflow/compiler/mlir/lite/quantization:quantization_lib",
        "//tensorflow/compiler/mlir/tensorflow",
        "@com_google_absl//absl/container:flat_hash_set",
        "@llvm-project//mlir:IR",
    ],
)

gentbl_cc_library(
    name = "replace_cast_hacks_with_tf_xla_ops_inc_gen",
    compatible_with = get_compatible_with_cloud(),
    tbl_outs = [
        (
            ["-gen-rewriters"],
            "passes/replace_cast_hacks_with_tf_xla_ops.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "passes/replace_cast_hacks_with_tf_xla_ops.td",
    deps = [":quant_td_files"],
)

cc_library(
    name = "passes",
    srcs = [
        "passes/convert_custom_aggregation_op_to_quant_stats.cc",
        "passes/convert_fake_quant_to_qdq.cc",
        "passes/convert_tf_quant_ops_to_mhlo.cc",
        "passes/insert_custom_aggregation_ops.cc",
        "passes/insert_main_function.cc",
        "passes/insert_quantized_functions.cc",
        "passes/issue_ids_of_custom_aggregation_ops.cc",
        "passes/lift_quantizable_spots_as_functions.cc",
        "passes/lift_quantizable_spots_as_functions.inc",
        "passes/lift_quantizable_spots_as_functions_drq.cc",
        "passes/lift_quantizable_spots_as_functions_drq.inc",
        "passes/merge_initializer_function_ops_to_main.cc",
        "passes/optimize.cc",
        "passes/optimize.inc",
        "passes/post_quantize.cc",
        "passes/post_quantize.inc",
        "passes/prepare_lifting.cc",
        "passes/prepare_lifting.inc",
        "passes/prepare_quantize.cc",
        "passes/prepare_quantize.inc",
        "passes/prepare_quantize_drq.cc",
        "passes/quantize.cc",
        "passes/quantize_composite_functions.cc",
        "passes/quantize_composite_functions.inc",
        "passes/quantized_function_library.h",
        "passes/replace_cast_hacks_with_tf_xla_ops.cc",
        "passes/replace_cast_hacks_with_tf_xla_ops.inc",
    ],
    hdrs = [
        "passes/passes.h",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        ":constants",
        ":pass_utils",
        ":quantization_options_proto_cc",
        ":tf_op_quant_spec",
        ":tf_quant_ops",
        "//tensorflow/compiler/mlir/lite:tensorflow_lite",
        "//tensorflow/compiler/mlir/lite/quantization:quantization_config",
        "//tensorflow/compiler/mlir/lite/quantization:quantization_lib",
        "//tensorflow/compiler/mlir/lite/quantization/ir:QuantOps",
        "//tensorflow/compiler/mlir/quantization/tensorflow/utils:fake_quant_utils",
        "//tensorflow/compiler/mlir/quantization/tensorflow/utils:lift_as_function_call_utils",
        "//tensorflow/compiler/mlir/quantization/tensorflow/utils:tf_to_xla_attribute_utils",
        "//tensorflow/compiler/mlir/tensorflow",
        "//tensorflow/compiler/mlir/tensorflow:error_util",
        "//tensorflow/compiler/mlir/tensorflow:import_model",
        "//tensorflow/compiler/mlir/tensorflow:mangling_util",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_ops",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_passes",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_types",
        "//tensorflow/compiler/mlir/xla:xla_legalize_tf",
        "//tensorflow/compiler/xla:xla_data_proto_cc",
        "//tensorflow/compiler/xla/mlir_hlo",
        "//tensorflow/core:framework",
        "//tensorflow/core:lib",
        "//tensorflow/core:protos_all_cc",
        "//tensorflow/core/ir/importexport:convert_tensor",
        "//tensorflow/core/ir/importexport:mangling",
        "//tensorflow/core/platform:env",
        "//tensorflow/core/platform:macros",
        "//tensorflow/core/platform:path",
        "//tensorflow/lite/kernels:padding",
        "//tensorflow/lite/kernels/internal:quantization_util",
        "//tensorflow/tsl/protobuf:protos_all_cc",
        "@com_google_absl//absl/algorithm:container",
        "@com_google_absl//absl/cleanup",
        "@com_google_absl//absl/container:flat_hash_set",
        "@com_google_absl//absl/random",
        "@com_google_absl//absl/strings",
        "@com_google_absl//absl/strings:str_format",
        "@llvm-project//llvm:Support",
        "@llvm-project//mlir:ArithDialect",
        "@llvm-project//mlir:FuncDialect",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:Parser",
        "@llvm-project//mlir:Pass",
        "@llvm-project//mlir:QuantOps",
        "@llvm-project//mlir:Support",
        "@llvm-project//mlir:TransformUtils",
        "@llvm-project//mlir:Transforms",
    ],
    alwayslink = 1,
)

cc_library(
    name = "quantize_preprocess",
    srcs = [
        "quantize_preprocess.cc",
    ],
    hdrs = [
        "quantize_preprocess.h",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "@llvm-project//mlir:ArithDialect",
        "@llvm-project//mlir:FuncDialect",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:Pass",
        "@llvm-project//mlir:QuantOps",
        "@llvm-project//mlir:SCFDialect",
        "@llvm-project//mlir:ShapeDialect",
        "@llvm-project//mlir:Transforms",
        "//tensorflow/cc/saved_model:loader",
        "//tensorflow/compiler/mlir/tensorflow",
        "//tensorflow/compiler/mlir/tensorflow:error_util",
        "//tensorflow/compiler/mlir/tensorflow:export_graphdef",
        "//tensorflow/compiler/mlir/tensorflow:mlir_import_options",
        "//tensorflow/compiler/mlir/tensorflow:mlir_roundtrip_flags",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_passes",
        "//tensorflow/compiler/mlir/tensorflow:tf_dialect_passes",
        "//tensorflow/compiler/mlir/tensorflow:tf_saved_model_freeze_variables",
        "//tensorflow/compiler/mlir/tensorflow:tf_saved_model_passes",
        "//tensorflow/compiler/mlir/tensorflow:translate_lib",
        "//tensorflow/core:protos_all_cc",
        "//tensorflow/core/platform:path",
        "//tensorflow/core/platform:statusor",
    ] + if_static(
        extra_deps = [
            "//tensorflow/compiler/mlir/quantization/tensorflow:quantization_options_proto_cc",
        ],
        otherwise = [
            "//tensorflow/compiler/mlir/quantization/tensorflow:quantization_options_proto_cc_headers_only",
        ],
    ),
    alwayslink = True,
)

cc_library(
    name = "quantize_passes",
    srcs = [
        "quantize_passes.cc",
    ],
    hdrs = [
        "quantize_passes.h",
    ],
    compatible_with = get_compatible_with_cloud(),
    deps = [
        "@llvm-project//mlir:ArithDialect",
        "@llvm-project//mlir:FuncDialect",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:Pass",
        "@llvm-project//mlir:QuantOps",
        "@llvm-project//mlir:SCFDialect",
        "@llvm-project//mlir:ShapeDialect",
        "@llvm-project//mlir:Transforms",
        "//tensorflow/cc/saved_model:loader",
        "//tensorflow/compiler/mlir/quantization/tensorflow:passes",
        "//tensorflow/compiler/mlir/tensorflow",
        "//tensorflow/compiler/mlir/tensorflow:error_util",
        "//tensorflow/compiler/mlir/tensorflow:export_graphdef",
        "//tensorflow/compiler/mlir/tensorflow:mlir_import_options",
        "//tensorflow/compiler/mlir/tensorflow:mlir_roundtrip_flags",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_passes",
        "//tensorflow/compiler/mlir/tensorflow:tf_dialect_passes",
        "//tensorflow/compiler/mlir/tensorflow:tf_saved_model_freeze_variables",
        "//tensorflow/compiler/mlir/tensorflow:tf_saved_model_passes",
        "//tensorflow/compiler/mlir/tensorflow:translate_lib",
        "//tensorflow/core:protos_all_cc",
        "//tensorflow/core/platform:path",
        "//tensorflow/core/platform:statusor",
    ] + if_static(
        extra_deps = [
            "//tensorflow/compiler/mlir/quantization/tensorflow:quantization_options_proto_cc",
        ],
        otherwise = [
            "//tensorflow/compiler/mlir/quantization/tensorflow:quantization_options_proto_cc_headers_only",
        ],
    ),
    alwayslink = True,
)

tf_proto_library(
    name = "quantization_options_proto",
    srcs = ["quantization_options.proto"],
    cc_api_version = 2,
)

# copybara:uncomment_begin(google-only)
# py_proto_library(
#     name = "quantization_options_py_pb2",
#     api_version = 2,
#     deps = [":quantization_options_proto"],
# )
# copybara:uncomment_end

tf_cc_binary(
    name = "tf-quant-opt",
    srcs = ["passes/tf_quant_opt.cc"],
    deps = [
        ":passes",
        "//tensorflow/compiler/mlir:init_mlir",
        "//tensorflow/compiler/mlir/lite/quantization/ir:QuantOps",
        "//tensorflow/compiler/mlir/tensorflow",
        "//tensorflow/compiler/mlir/tensorflow:tensorflow_passes",
        "//tensorflow/compiler/mlir/tensorflow:tf_dialect_passes",
        "@llvm-project//mlir:AllPassesAndDialects",
        "@llvm-project//mlir:FuncDialect",
        "@llvm-project//mlir:MlirOptLib",
        "@llvm-project//mlir:QuantOps",
        "@llvm-project//mlir:SCFDialect",
        "@llvm-project//mlir:ShapeDialect",
    ],
)
