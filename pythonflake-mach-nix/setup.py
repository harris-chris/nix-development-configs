from distutils.core import setup
setup(
    name='pythonflake-mach-nix',
    packages=['pythonflake_mach_nix'],
    package_dir={'pythonflake_mach_nix': 'pythonflake_mach_nix'},
    version='0.1.0',
    entry_points={
        'console_scripts': ['pythonflake-mach-nix=pythonflake_mach_nix.__main__:main' ]
    }
    )
