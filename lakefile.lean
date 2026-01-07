import Lake
open Lake DSL System

package raster where
  version := v!"0.1.0"
  precompileModules := true

require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.3"
require staple from git "https://github.com/nathanial/staple" @ "v0.0.2"

@[default_target]
lean_lib Raster where
  roots := #[`Raster]

lean_lib Tests where
  roots := #[`Tests]

@[test_driver]
lean_exe raster_tests where
  root := `Tests.Main

-- Compile stb implementation (FFI bridge with stb headers)
target raster_ffi_o pkg : FilePath := do
  let oFile := pkg.buildDir / "native" / "raster_ffi.o"
  let srcFile := pkg.dir / "native" / "src" / "raster_ffi.c"
  let stbInclude := pkg.dir / "native" / "stb"
  let leanIncludeDir ← getLeanIncludeDir
  buildO oFile (← inputTextFile srcFile) #[
    "-I", leanIncludeDir.toString,
    "-I", stbInclude.toString,
    "-fPIC",
    "-O2"
  ] #[] "cc" getLeanTrace

extern_lib raster_native pkg := do
  let name := nameToStaticLib "raster_native"
  let ffiO ← raster_ffi_o.fetch
  buildStaticLib (pkg.buildDir / "lib" / name) #[ffiO]
