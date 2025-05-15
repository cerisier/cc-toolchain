
def arch_to_kernel_arch(arch):
    """Convert the architecture name used in the glibc to the one used in the kernel."""
    if arch == "x86_64":
        return "x86"
    elif arch == "aarch64":
        return "arm64"
    elif arch == "armv7":
        return "arm"
    else:
        return arch
