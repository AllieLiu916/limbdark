# Tests automatic differentiation on sn.jl:
include("sn_jacobian.jl")
using PyPlot

function test_sn_jacobian2(l_max)
r0 = [0.01,100.0]
nb = 50
#l_max = 20
#l_max = 5
n_max = l_max^2+2*l_max

# Now, carry out finite-difference derivative computation:
function sn_jac_num(l_max::Int64,r::T,b::T) where {T <: Real}
  dq = big(1e-24)
  n_max = l_max^2+2*l_max
# Allocate an array for s_n:
  sn_big = zeros(BigFloat,n_max+1)
# Make BigFloat versions of r & b:
  r_big = big(r); b_big = big(b)
# Compute s_n to BigFloat precision:
  s_n_bigr!(l_max,r_big,b_big,sn_big)
# Now, compute finite differences:
  sn_jac_big= zeros(BigFloat,n_max+1,2)
  sn_plus = zeros(BigFloat,n_max+1)
  s_n_bigr!(l_max,r_big+dq,b_big,sn_plus)
  sn_minus = zeros(BigFloat,n_max+1)
  s_n_bigr!(l_max,r_big-dq,b_big,sn_minus)
  sn_jac_big[:,1] = (sn_plus-sn_minus)*.5/dq
  s_n_bigr!(l_max,r_big,b_big+dq,sn_plus)
  s_n_bigr!(l_max,r_big,b_big-dq,sn_minus)
  sn_jac_big[:,2] = (sn_plus-sn_minus)*.5/dq
return convert(Array{Float64,1},sn_big),convert(Array{Float64,2},sn_jac_big)
end


#sn_jacobian
#convert(Array{Float64,2},sn_jac_big)-sn_jacobian

get_cmap("plasma")
epsilon = 1e-12; delta = 1e-3
for i=1:2
  fig,axes = subplots(1,1)
  r=r0[i]
  if r < 1.0
    b = [linspace(1e-15,epsilon,nb); linspace(epsilon,delta,nb); linspace(delta,r-delta,nb);
     r-logspace(log10(delta),log10(epsilon),nb); linspace(r-epsilon,r+epsilon,nb); r+logspace(log10(epsilon),log10(delta),nb);
     linspace(r+delta,1-r-delta,nb); 1-r-logspace(log10(delta),log10(epsilon),nb); linspace(1-r-epsilon,1-r+epsilon,nb);
     1-r+logspace(log10(epsilon),log10(delta),nb); linspace(1-r+delta,1+r-delta,nb); 1+r-logspace(log10(delta),log10(epsilon),nb);linspace(1+r-epsilon,1+r-1e-15,nb)]
     nticks = 14
     xticknames=[L"$10^{-15}$",L"$10^{-12}$",L"$10^{-3}$",L"$r-10^{-3}$",L"$r-10^{-12}$",L"$r+10^{-12}$",L"$r+10^{-3}$",
     L"$1-r-10^{-3}$",L"$1-r-10^{-12}$",L"$1-r+10^{-12}$",L"$1-r+10^{-3}$",L"$1+r-10^{-3}$",L"$1+r-10^{-12}$",L"$1+r-10^{-15}$"]
  else
    b = [r-1+logspace(log10(epsilon),log10(delta),nb); linspace(r-1+delta,r-delta,nb);
     r-logspace(log10(delta),log10(epsilon),nb); linspace(r-epsilon,r+epsilon,nb); r+logspace(log10(epsilon),log10(delta),nb);
     linspace(r+delta,r+1-delta,nb); r+1-logspace(log10(delta),log10(epsilon),nb)]
     nticks = 8
     xticknames=[L"$r-1+10^{-12}$",L"$r-1+10^{-3}$",L"$r-10^{-3}$",L"$r-10^{-12}$",L"$r+10^{-12}$",L"$r+10^{-3}$",
     L"$r+1-10^{-3}$",L"$r+1-10^{-12}$"]
  end
#  if r < 1.0
#    b = [linspace(1e-8,epsilon,nb); linspace(epsilon,delta,nb); linspace(delta,r-delta,nb);
##     linspace(r-delta,r-epsilon,nb); linspace(r-epsilon,r,nb); linspace(r,r+epsilon,nb); linspace(r+epsilon,r+delta,nb);  
#     linspace(r-delta,r-epsilon,nb); linspace(r-epsilon,r+epsilon,nb); linspace(r+epsilon,r+delta,nb);  
#     linspace(r+delta,1-r-delta,nb); linspace(1-r-delta,1-r-epsilon,nb); linspace(1-r-epsilon,1-r+epsilon,nb);
#     linspace(1-r+epsilon,1-r+delta,nb); linspace(1-r+delta,1+r-delta,nb); linspace(1+r-delta,1+r-epsilon,nb);linspace(1+r-epsilon,1+r-1e-8,nb)]
#  else
#    b = [linspace(r-1+1e-8,r-1+epsilon,nb); linspace(r-1+epsilon,r-1+delta,nb); linspace(r-1+delta,r-delta,nb); 
##     linspace(r-delta,r-epsilon,nb); linspace(r-epsilon,r,nb); linspace(r,r+epsilon,nb); linspace(r+epsilon,r+delta,nb);  
#     linspace(r-delta,r-epsilon,nb); linspace(r-epsilon,r+epsilon,nb); linspace(r+epsilon,r+delta,nb);  
#     linspace(r+delta,r+1-delta,nb); linspace(r+1-delta,r+1-epsilon,nb); linspace(r+1-epsilon,r+1-1e-8,nb)]
#  end
  k2 = (1.-(r-b).^2)./(4.*b.*r)
  k2H = ((b+1).^2-r.^2)./(4b)
  igrid=linspace(1,length(b),length(b))-1
  sn_jac_grid = zeros(length(b),n_max+1,2)
  sn_jac_array= zeros(n_max+1,2)
  sn_grid = zeros(length(b),n_max+1)
  sn_grid_big = zeros(length(b),n_max+1)
  sn_array= zeros(n_max+1)
  sn_jac_grid_num = zeros(length(b),n_max+1,2)
  for j=1:length(b)
    println("r: ",r," b: ",b[j])
    sn_array,sn_jac_array= sn_jac(l_max,r,b[j])
    s_n_bigr!(l_max,r,b[j],sn_array)
    sn_grid[j,:]=sn_array
    sn_jac_grid[j,:,:]=sn_jac_array
    sn_array,sn_jac_array = sn_jac_num(l_max,r,b[j]) 
    sn_jac_grid_num[j,:,:]=sn_jac_array
    sn_grid_big[j,:]=sn_array
  end
# Now, make plots:
  ax = axes
  m=0;l=0
  for n=0:n_max
    if m==0
#      ax[:plot](abs.(sn_jac_grid[:,n+1,1]-sn_jac_grid_num[:,n+1,1]),color=cmap(l/(l_max+2)),lw=1,label=string("l=",l))
#      ax[:semilogy](abs.(asinh.(sn_jac_grid[:,n+1,1])-sn_jac_grid_num[:,n+1,1]),lw=1,label=string("l=",l))
#      ax[:semilogy](b,abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1,label=string("l=",l))
#      ax[:semilogy](abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1,label=string("l=",l))
      ax[:semilogy](abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1,label=string("l=",l))
#      semilogy(abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1,label=string("l=",l))
    else
#      ax[:plot](abs.(sn_jac_grid[:,n+1,1]-sn_jac_grid_num[:,n+1,1]),color=cmap(l/(l_max+2)),lw=1)
#      ax[:semilogy](abs.(sn_jac_grid[:,n+1,1]-sn_jac_grid_num[:,n+1,1]),lw=1)
      ax[:semilogy](abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1)
#      semilogy(abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1)
#      ax[:semilogy](b,abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1])),lw=1)
    end
#    ax[:plot](abs.(sn_jac_grid[:,n+1,2]-sn_jac_grid_num[:,n+1,2]),color=cmap(l/(l_max+2)),lw=1)
#    ax[:semilogy](abs.(sn_jac_grid[:,n+1,2]-sn_jac_grid_num[:,n+1,2]),lw=1)
#    ax[:semilogy](b,abs.(asinh.(sn_jac_grid[:,n+1,2])-asinh.(sn_jac_grid_num[:,n+1,2])),lw=1)
    ax[:semilogy](abs.(asinh.(sn_jac_grid[:,n+1,2])-asinh.(sn_jac_grid_num[:,n+1,2])),lw=1)
    ax[:semilogy](abs.(asinh.(sn_grid[:,n+1])-asinh.(sn_grid_big[:,n+1])),lw=1)
#    semilogy(abs.(asinh.(sn_jac_grid[:,n+1,2])-asinh.(sn_jac_grid_num[:,n+1,2])),lw=1)
    println("n: ",n," m: ",m," l: ",l," mu: ",l-m," nu: ",l+m," max dsn/dr: ",maximum(abs.(asinh.(sn_jac_grid[:,n+1,1])-asinh.(sn_jac_grid_num[:,n+1,1]))),
      " maximum dsn/db: ",maximum(abs.(asinh.(sn_jac_grid[:,n+1,2])-asinh.(sn_jac_grid_num[:,n+1,2]))))
    m +=1
    if m > l
      l += 1
      m = -l
    end
  end
  ax[:legend](loc="upper right",fontsize=6)
  ax[:set_xlabel]("b values")
  ax[:set_ylabel]("Derivative Error")
  ax[:axis]([0,length(b),1e-16,1])
  ax[:set_xticks](nb*linspace(0,nticks-1,nticks))
  ax[:set_xticklabels](xticknames,rotation=45)
  if i==1 
    ax[:set_title]("r = 0.01")
  else
    ax[:set_title]("r = 100")
  end
#  ax[:axis]([minimum(b),maximum(b),1e-16,1])
#  ax[:axis]([0,length(b),1e-16,1])
  read(STDIN,Char)
  clf()
  for n=0:n_max
      plot(b,sn_grid[:,n+1])
  end
  read(STDIN,Char)
## Loop over n and see where the differences between the finite-difference
## and AutoDiff are greater than the derivative value: 
l=0; m=0
for n=0:n_max
  diff = sn_jac_grid[:,n+1,:]-sn_jac_grid_num[:,n+1,:]
  mask = (abs.(diff) .> 1e-3*abs.(sn_jac_grid[:,n+1,:])) .& (abs.(sn_jac_grid[:,n+1,:]) .> 1e-5)
  if sum(mask) > 0 || mod(l-m,4) == 0
    println("n: ",n," max dsn/dr: ",maximum(abs.(diff)))
    println("b: ",b[mask[:,1]],b[mask[:,2]]," k^2_H: ",k2H[mask[:,1]],k2H[mask[:,2]])
# end
#end
# Now, plot derivatives for each value of n:
#for n=0:n_max
    clf()
#    plot(sn_grid[:,n+1])
#    plot(sn_jac_grid[:,n+1,1])
#    plot(igrid[mask[:,1]],sn_jac_grid[mask[:,1],n+1,1],"o")
#    plot(sn_jac_grid[:,n+1,2])
#    plot(igrid[mask[:,2]],sn_jac_grid[mask[:,2],n+1,2],"o")
#    plot(igrid,sn_jac_grid_num[:,n+1,1],linestyle="--",linewidth=2)
#    plot(igrid,sn_jac_grid_num[:,n+1,2],linestyle="--",linewidth=2)
    plot(b,sn_grid[:,n+1])
    plot(b,sn_jac_grid[:,n+1,1])
    plot(b[mask[:,1]],sn_jac_grid[mask[:,1],n+1,1],"o")
    plot(b,sn_jac_grid[:,n+1,2])
    plot(b[mask[:,2]],sn_jac_grid[mask[:,2],n+1,2],"o")
    plot(b,sn_jac_grid_num[:,n+1,1],linestyle="--",linewidth=2)
    plot(b,sn_jac_grid_num[:,n+1,2],linestyle="--",linewidth=2)
    println("n: ",n," l: ",l," m: ",m," mu: ",l-m," nu: ",l+m)
    read(STDIN,Char)
  end
  m +=1
  if m > l
    l += 1
    m = -l
  end
end
#
#
##end
#
##loglog(abs.(reshape(sn_jac_grid,length(b)*(n_max+1)*2)),abs.(reshape(sn_jac_grid-sn_jac_grid_num,length(b)*(n_max+1)*2)),".")
##loglog(abs.(reshape(sn_jac_grid,length(b)*(n_max+1)*2)),abs.(reshape(sn_jac_grid_num,length(b)*(n_max+1)*2)),".")
end
return
end
