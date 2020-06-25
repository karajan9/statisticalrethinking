
a = Turing.getargnames(divorce_AM)
m5_3 = divorce_AM(eachcol(d[!, [a...]])...)
b = typeof(m5_3)
c = Turing.VarInfo(m5_3)
d = Turing.tonamedtuple(c) |> keys
