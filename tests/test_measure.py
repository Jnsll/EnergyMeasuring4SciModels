import sys
sys.path.append('../experimentation')
from experimentation import measure



def test_fibonacci():
    assert measure.fibonacci(5) == 5
    assert measure.fibonacci(10) == 55
    assert measure.fibonacci(-5) == 0