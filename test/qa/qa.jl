using SciMLTesting, MathML, Test
using JET

# Aqua piracies: `children`/`printnode`/`nodetype` are owned by AbstractTrees and
# defined on EzXML.Node in src/utils.jl — neither name nor argument type is owned by
# MathML, so Aqua flags type piracy. These are AbstractTrees-interface bindings for
# walking EzXML trees and cannot be made non-pirate without an upstream/glue change;
# tracked in https://github.com/SciML/MathML.jl/issues/104.
#
# ExplicitImports qualified-access ignores are all *other packages'* non-public
# names that MathML legitimately uses:
#   all_qualified_accesses_via_owners:
#     toexpr     — owned by SymbolicUtils.Code, re-exported via Symbolics
#   all_qualified_accesses_are_public:
#     Document   — EzXML (not declared public)
#     Node       — EzXML (not declared public)
#     ifelse     — IfElse (not declared public)
#     printnode  — AbstractTrees (not declared public)
#     toexpr     — Symbolics (not declared public; SymbolicUtils-owned)
run_qa(
    MathML;
    explicit_imports = true,
    aqua_broken = (:piracies,),
    ei_kwargs = (;
        all_qualified_accesses_via_owners = (; ignore = (:toexpr,)),
        all_qualified_accesses_are_public = (;
            ignore = (:Document, :Node, :ifelse, :printnode, :toexpr),
        ),
    ),
)
