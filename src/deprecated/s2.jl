# Computes the s_2 function.
include("ellpic_bulirsch.jl")

function s2(r::T,b::T,Kofk::T,Eofk::T) where {T <: Real}
# For now, just compute linear component:
Lambda1 = zero(typeof(b))
if b > 1.0+r ||  r == 0.0
  # No occultation:
  Lambda1 = 0  # Case 1
elseif b < r-1.0
  # Full occultation:
  Lambda1 = 0  # Case 11
else
  if b == 0
    Lambda1 = -2/3*(1.0-r^2)^(3/2) # Case 10
  elseif b==r
    if r == 0.5
      Lambda1 = 1/3-4/(9pi) # Case 6
    elseif r < 0.5
#      Kofk = ellk_bulirsch(4r^2); Eofk = ellec_bulirsch(4r^2)
#      Lambda1 = 1/3+2/(9pi)*(4*(2r^2-1)*ellec_bulirsch(4r^2)+(1-4r^2)*ellk_bulirsch(4r^2)) # Case 5
      Lambda1 = 1/3+2/(9pi)*(4*(2r^2-1)*Eofk+(1-4r^2)*Kofk) # Case 5
    else
#      Kofk = ellk_bulirsch(inv(4r^2)); Eofk = ellec_bulirsch(inv(4r^2))
#      Lambda1 = 1/3+16r/(9pi)*(2r^2-1)*ellec_bulirsch(inv(4r^2))-(1-4r^2)*(3-8r^2)/(9pi*r)*ellk_bulirsch(inv(4r^2)) # Case 7
      Lambda1 = 1/3+16r/(9pi)*(2r^2-1)*Eofk-(1-4r^2)*(3-8r^2)/(9pi*r)*Kofk # Case 7
    end
  else
    k2 = 1.0+(1.0-(b+r)^2)/(4*b*r)
    if (b+r) > 1.0 # k^2 < 1, Case 2, Case 8
#      Kofk = ellk_bulirsch(k2)
#      Eofk = ellec_bulirsch(k2)
      Piofnk = ellpic_bulirsch(-k2*(b+r)^2,k2)
      xi = 2*b*r*(4-7r^2-b^2)
      Lambda1 = (((r+b)^2-1)/(r+b)*(-2r*(2*(r+b)^2+(r+b)*(r-b)-3)*Kofk+3*(b-r)*Piofnk)
            -2*xi*Eofk)/(9*pi*sqrt(b*r))
    elseif (b+r) < 1.0  # k^2 > 1, Case 3, Case 9
      k2inv = inv(k2)
#      Kofk = ellk_bulirsch(k2inv)
#      Eofk = ellec_bulirsch(k2inv)
      if abs(b-r) != 1.0
        Piofnk = ellpic_bulirsch(-inv(k2*(b+r)^2),k2inv)/sqrt(1-(b-r)^2)
      else
        Piofnk = 0.0
      end
      Lambda1 = 2*((1-(r+b)^2)*(sqrt(1-(b-r)^2)*Kofk+3*(b-r)/(b+r)*Piofnk)
            -sqrt(1-(b-r)^2)*(4-7r^2-b^2)*Eofk)/(9*pi)
    else
      # b+r = 1 or k^2=1, Case 4 (extending r up to 1)
      Lambda1 = 2/(3pi)*acos(1.-2*r)-4/(9pi)*(3+2r-8r^2)*sqrt(r*b)-2/3*convert(typeof(b),r>.5)
    end
  end
end
s2 = 1.0-1.5*Lambda1-convert(typeof(b),r>b)
return s2*2pi/3
end

