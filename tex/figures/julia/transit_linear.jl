# Uses new formulation from limbdark paper.

include("../../../src/s2.jl")
include("../../../src/define_constants.jl")

# Run some tests:

using PyPlot
nb = 401; nr = 401
b=linspace(0.0,2,nr)
r=linspace(0.0,2,nr)
fgrid = zeros(Float64,nr,nb)
for ib=1:nb
#  if mod(ib,10) == 0
#    println("Finished: ",ib/nr*100,"%")
#  end
  for ir=1:nr
    fgrid[ir,ib]=s2(r[ir],b[ib])
  end
end

clf()
img=imshow(fgrid,interpolation="nearest",origin="lower",extent=[0,2,0,2],
           cmap="plasma")
plot([0,1],[1,2],"k-")
plot([1,2],[0,1],"k-")
plot([0,0.38],[0,0.38],"k-")
plot([0.5,2],[0.5,2],"k-")
plot([0,1],[1,0],"k-")

annotate(L"$r = 1 + b$", xy=(0.5, 1.5), xytext=(0, 0), xycoords="data",
         textcoords="offset points", ha="center", va="bottom",
         fontsize=12, color="w", rotation=45)

annotate(L"$r = b$", xy=(1, 1), xytext=(0, 0), xycoords="data",
         textcoords="offset points", ha="center", va="bottom",
         fontsize=12, color="k", rotation=45)

annotate(L"$r = b - 1$", xy=(1.5, 0.5), xytext=(0, 0), xycoords="data",
         textcoords="offset points", ha="center", va="bottom",
         fontsize=12, color="k", rotation=45)

annotate(L"$r = 1 - b$", xy=(0.5, 0.5), xytext=(-9, -9), xycoords="data",
         textcoords="offset points", ha="center", va="center",
         fontsize=12, color="k", rotation=-45)

xlabel("Impact parameter")
ylabel("Radius ratio")
colorbar(img)
savefig("transit_linear.pdf", bbox_inches="tight")
