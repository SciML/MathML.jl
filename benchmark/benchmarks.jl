using MathML, BenchmarkTools

const SUITE = BenchmarkGroup()

str_apply = """
<apply>
  <plus/>
  <ci>x</ci>
  <apply><times/><cn>2</cn><ci>y</ci></apply>
</apply>
"""

str_nested = """
<apply>
  <plus/>
  <apply><exp/><ci>x</ci></apply>
  <apply><divide/><cn>1</cn><apply><plus/><ci>y</ci><cn>3</cn></apply></apply>
  <apply><power/><ci>z</ci><cn>2</cn></apply>
</apply>
"""

str_eq = """
<math xmlns="http://www.w3.org/1998/Math/MathML">
  <apply>
    <eq/>
    <apply><plus/><ci>x</ci><cn>1</cn></apply>
    <cn>2</cn>
  </apply>
</math>
"""

# =============================================================================
# Parsing
# =============================================================================

SUITE["parse"] = BenchmarkGroup()

SUITE["parse"]["apply"] = @benchmarkable MathML.parse_str($str_apply)
SUITE["parse"]["nested"] = @benchmarkable MathML.parse_str($str_nested)
SUITE["parse"]["equation"] = @benchmarkable MathML.parse_str($str_eq)
