fn main() {
    let homebrew_prefix = std::env::var("HOMEBREW_PREFIX").unwrap_or_else(|_| "/opt/homebrew".to_string());
    let libkrun_path = std::path::Path::new(&homebrew_prefix).join("opt/libkrun/lib");

    if libkrun_path.exists() {
        println!("cargo:rustc-link-search={}", libkrun_path.display());
    }

    println!(
        "cargo:rustc-link-search=framework={}",
        "/System/Library/PrivateFrameworks"
    );
}
