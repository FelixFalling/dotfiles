# ~/.gdbinit — GDB configuration
#
# Security: Prevent automatic execution of untrusted local .gdbinit files
# found in current working directories (CWE-426).
set auto-load local-gdbinit off

# Splitmind: load safely if installed in ~/.config/gdb/splitmind
python
import os, sys
splitmind_dir = os.path.expanduser("~/.config/gdb/splitmind")
splitmind_init = os.path.join(splitmind_dir, "gdbinit.py")
if os.path.isfile(splitmind_init):
    if splitmind_dir not in sys.path:
        sys.path.insert(0, splitmind_dir)
    import gdb
    gdb.execute(f"source {splitmind_init}")
    try:
        import splitmind
        (splitmind.Mind()
          .below(display="backtrace")
          .right(display="stack")
          .right(display="regs")
          .right(of="main", display="disasm")
          .show("legend", on="disasm")
        ).build()
    except Exception:
        pass
end
