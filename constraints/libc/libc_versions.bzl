GLIBC_VERSIONS = [
    2.17,
    2.18,
    2.19,
    2.22,
    2.23,
    2.24,
    2.25,
    2.26,
    2.27,
    2.28,
    2.29,
    2.30,
    2.31,
    2.32,
    2.33,
    2.34,
    2.35,
    2.36,
    2.37,
    2.38,
]

GLIBCS = ["gnu.{}".format(glibc) for glibc in GLIBC_VERSIONS]

LIBCS = ["musl"] + GLIBCS

