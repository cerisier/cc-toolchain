load("//constraints/libc:libc_versions.bzl", "LIBCS")
load("//platforms:platforms.bzl", "CPUS", "LIBC_OS")

# For use with zig tools that consume parse zig targets triples
# Zig target triples only, not LLVM
def libc_aware_target_triple():
    target = {}
    for bzlcpu, _ in CPUS:
        for os in LIBC_OS:
            target["//platforms/config/libc_aware:{}_{}".format(os, bzlcpu)] = "{}-{}-gnu".format(bzlcpu, os)

    for bzlcpu, _ in CPUS:
        for os in LIBC_OS:
            for libc in LIBCS:
                target["//platforms/config/libc_aware:{}_{}_{}".format(os, bzlcpu, libc)] = "{}-{}-{}".format(bzlcpu, os, libc)

    return select(target)

