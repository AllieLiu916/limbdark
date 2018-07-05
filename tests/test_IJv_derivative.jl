# Tests the code for computing the derivatives
# of I_v and J_v with respect to k.
include("../src/IJv_derivative.jl")

@testset "IJv_derivative" begin

function test_IJv_derivative(k2::Float64)
v_max = 20
Iv = zeros(Float64,v_max+1); Jv = zeros(Float64,v_max+1)
Iv_bigp = zeros(BigFloat,v_max+1); Jv_bigp = zeros(BigFloat,v_max+1)
Iv_bigm = zeros(BigFloat,v_max+1); Jv_bigm = zeros(BigFloat,v_max+1)
dIvdk = zeros(Float64,v_max+1); dJvdk = zeros(Float64,v_max+1)
dIvdk_big = zeros(BigFloat,v_max+1); dJvdk_big = zeros(BigFloat,v_max+1)
dIvdk2_num = zeros(Float64,v_max+1); dJvdk2_num = zeros(Float64,v_max+1)
# This computes I_v for the largest v, and then works down to smaller values:
dq = big(1e-20)
if k2 <= 1
  kc = sqrt(1.-k2)
else
  kc = sqrt(1.-inv(k2))
end
k = sqrt(k2)
if k2 > 0
  if k2 < 0.5 || k2 > 2.0
    dIJv_lower_dk!(v_max,k2,kc,Iv,Jv,dIvdk,dJvdk)
    if k2 <=1 
      dIJv_lower_dk!(v_max,big(k2)+dq,sqrt(1-big(k2)-dq),Iv_bigp,Jv_bigp,dIvdk_big,dJvdk_big)
      dIJv_lower_dk!(v_max,big(k2)-dq,sqrt(1-big(k2)+dq),Iv_bigm,Jv_bigm,dIvdk_big,dJvdk_big)
    else
      dIJv_lower_dk!(v_max,big(k2)+dq,sqrt(1-inv(big(k2)+dq)),Iv_bigp,Jv_bigp,dIvdk_big,dJvdk_big)
      dIJv_lower_dk!(v_max,big(k2)-dq,sqrt(1-inv(big(k2)-dq)),Iv_bigm,Jv_bigm,dIvdk_big,dJvdk_big)
    end
    for v=0:v_max
      dIvdk2_num[v+1] = convert(Float64,(Iv_bigp[v+1]-Iv_bigm[v+1])/(2dq))
      dJvdk2_num[v+1] = convert(Float64,(Jv_bigp[v+1]-Jv_bigm[v+1])/(2dq))
      @test isapprox(dIvdk[v+1],dIvdk2_num[v+1]*2*k)
      @test isapprox(dJvdk[v+1],dJvdk2_num[v+1]*2*k)
      println("v: ",v," k2: ",k2," kc: ",kc," dIvdk: ",dIvdk[v+1]," dIvdk_num: ",dIvdk2_num[v+1]*2*k," diff: ",dIvdk[v+1]-dIvdk2_num[v+1]*2*k," dJvdk: ",dJvdk[v+1]," dJvdk_num: ",dJvdk2_num[v+1]*2*k," diff: ",dJvdk[v+1]-dJvdk2_num[v+1]*2*k)
    end
  else
    dIJv_raise_dk!(v_max,k2,kc,Iv,Jv,dIvdk,dJvdk)
    if k2 <=1 
      dIJv_raise_dk!(v_max,big(k2)+dq,sqrt(1-big(k2)-dq),Iv_bigp,Jv_bigp,dIvdk_big,dJvdk_big)
      dIJv_raise_dk!(v_max,big(k2)-dq,sqrt(1-big(k2)+dq),Iv_bigm,Jv_bigm,dIvdk_big,dJvdk_big)
    else
      dIJv_raise_dk!(v_max,big(k2)+dq,sqrt(1-inv(big(k2)+dq)),Iv_bigp,Jv_bigp,dIvdk_big,dJvdk_big)
      dIJv_raise_dk!(v_max,big(k2)-dq,sqrt(1-inv(big(k2)-dq)),Iv_bigm,Jv_bigm,dIvdk_big,dJvdk_big)
    end
    for v=0:v_max
      dIvdk2_num[v+1] = convert(Float64,(Iv_bigp[v+1]-Iv_bigm[v+1])/(2dq))
      dJvdk2_num[v+1] = convert(Float64,(Jv_bigp[v+1]-Jv_bigm[v+1])/(2dq))
      @test isapprox(dIvdk[v+1],dIvdk2_num[v+1]*2*k)
      @test isapprox(dJvdk[v+1],dJvdk2_num[v+1]*2*k)
#      println("v: ",v," k2: ",k2," kc: ",kc," dIvdk2: ",dIvdk[v+1]/(2*k)," dIvdk2_num: ",dIvdk2_num[v+1]," dJvdk2: ",dJvdk[v+1]/(2k)," dJvdk2_num: ",dJvdk2_num[v+1])
      println("v: ",v," k2: ",k2," kc: ",kc," dIvdk: ",dIvdk[v+1]," dIvdk_num: ",dIvdk2_num[v+1]*2*k," diff: ",dIvdk[v+1]-dIvdk2_num[v+1]*2*k," dJvdk: ",dJvdk[v+1]," dJvdk2_num: ",dJvdk2_num[v+1]*2*k," diff: ",dJvdk[v+1]-dJvdk2_num[v+1]*2*k)
    end
  end
end
return
end

r=100.0; b0=[r-1+1e-10,r,r+1-1e-10]
for i=1:length(b0)
  b=b0[i]
  k2 = (1-b+r)*(1+b-r)/(4*b*r)
  test_IJv_derivative(k2)
end
r=0.01; b0=[1e-10,r,1-r-1e-10,1-r+1e-10,1.0,r+1-1e-10]
for i=1:length(b0)
  b=b0[i]
  k2 = (1-b+r)*(1+b-r)/(4*b*r)
  test_IJv_derivative(k2)
end
test_IJv_derivative(.5*rand())
test_IJv_derivative(.5+.5*rand())
test_IJv_derivative(inv(.5+.5*rand()))
test_IJv_derivative(inv(.5*rand()))

end
