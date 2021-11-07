import fxpmath
from fxpmath import Fxp


# def get_sample(self, n, f):
#   num = Fxp(val=(-1)**(random.randint(0, 1))*(random.random()), signed=1, n_word=n, n_frac=f)
#   snum = num.base_repr(2)
#   inum = int(snum, 2)
#   return inum

def conv():
  pass

a = Fxp(val=None, signed=True, n_word=32, n_frac=31)
b = Fxp(val=None, signed=True, n_word=32, n_frac=31)
mult = Fxp(val=None, signed=True, n_word=64, n_frac=62)
acc = Fxp(val=None, signed=True, n_word=64, n_frac=62)



a(0.3556001)
b(-0.811401)


mult = a * b

print(a.info())
print(b.info())
print(mult.info())