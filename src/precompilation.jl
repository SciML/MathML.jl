using PrecompileTools

@setup_workload begin
    # Simple MathML strings for precompilation
    # These cover the most common parsing operations

    simple_apply = """<math xmlns="http://www.w3.org/1998/Math/MathML">
      <apply>
        <plus/>
        <ci>x</ci>
        <cn>1</cn>
      </apply>
    </math>"""

    arithmetic_expr = """<apply><times/>
      <apply><plus/><ci>x</ci><ci>y</ci></apply>
      <apply><minus/><ci>a</ci><ci>b</ci></apply>
    </apply>"""

    trig_expr = """<apply><sin/><ci>x</ci></apply>"""

    piecewise_expr = """<piecewise>
      <piece>
        <ci>x</ci>
        <apply><gt/><ci>x</ci><cn>0</cn></apply>
      </piece>
      <otherwise>
        <cn>0</cn>
      </otherwise>
    </piecewise>"""

    vector_expr = """<vector>
      <cn>1</cn>
      <cn>2</cn>
      <cn>3</cn>
    </vector>"""

    @compile_workload begin
        # Precompile the main parsing functions
        parse_str(simple_apply)
        parse_str(arithmetic_expr)
        parse_str(trig_expr)
        parse_str(piecewise_expr)
        parse_str(vector_expr)
    end
end
