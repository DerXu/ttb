# Tensor Toolbox for Modern Fortran (ttb)

Commercial FEM software packages often offer interfaces (user subroutines written in Fortran) for custom defined user materials like UMAT in [Abaqus](https://www.3ds.com/products-services/simulia/products/abaqus/) or HYPELA2 in [MSC.Marc](http://www.mscsoftware.com/product/marc). Unlike other scientific programming languages like MATLAB or Python Fortran is not as comfortable to use when dealing with high level programming features of tensor manipulation. On the other hand it's super fast - so why not combine the handy features from MATLAB or Python's NumPy/Scipy with the speed of Fortran? That's the reason why I started working on a simple but effective module called **Tensor Toolbox for Modern Fortran**. I adopted the idea to my needs from [Naumann, C. (2016)](http://nbn-resolving.de/urn:nbn:de:bsz:ch1-qucosa-222075).

It provides the following [basic operations for tensor calculus](functions.md) (all written in double precision `real(kind=8)`):
- Dot Product `C(i,j) = A(i,k) B(k,j)` written as `C = A*B` or `C = A.dot.B`
- Double Dot Product `C = A(i,j) B(i,j)` written as `C = A**B` or `C = A.ddot.B`
- Dyadic Product `C(i,j,k,l) = A(i,j) B(k,l)` written as `C = A.dya.B`
- Crossed Dyadic Product `C(i,j,k,l) = (A(i,k) B(j,l) + A(i,l) B(j,k))/2` written as `C = A.cdya.B`
- Addition `C(i,j) = A(i,j) + B(i,j)` written as `C = A+B` or `C = A.add.B`
- Subtraction `C(i,j) = A(i,j) - B(i,j)` written as `C = A-B` or `C = A.sub.B`
- Multiplication and Division by a Scalar
- Deviatoric Part of Tensor  `dev(C) = C - tr(C)/3 * Eye` written as `dev(C)`
- Transpose and Permutation of indices `B(i,j,k,l) = A(i,k,j,l)` written as `B = permute(A,1,3,2,4)`
- Rank 2 Identity tensor of input type `Eye = identity2(Eye)` with `C = Eye*C`
- Rank 4 Identity tensor (symmetric variant) of input type `I4 = identity4(Eye)` with `C = I4(Eye)**C` or `inv(C) = identitiy4(inv(C))**C`
- Square Root of a positive definite rank 2 tensor `U = sqrt(C)`
- Natural logarithm of a rank 2 tensor `lnC = ln(C)`
- Exponential function of a rank 2 tensor `expC = exp(C)`
- Assigment of a real-valued Scalar to all components of a Tensor `A = 0.0` or `A = 0.d0`
- Assigment of a real-valued Array to a Tensor with matching dimensions `A = B` where B is an Array and A a Tensor
- Assigment of a Tensor in Voigt notation to a Tensor in tensorial notation
- Assigment of a Tensor in tensorial notation to a Tensor in Voigt notation 

The idea is to create derived data types for rank 1, rank 2 and rank 4 tensors (and it's symmetric variants). In a next step the operators are defined in a way that Fortran calls different functions based on the input types of the operator: performing a dot product between a vector and a rank 2 tensor or a rank 2 and a rank 2 tensor is a different function. Best of it: you don't have to take care of that.

## Basic Usage
The most basic example on how to use this module is to [download the module](https://github.com/adtzlr/ttb/archive/master.zip), put the 'ttb'-Folder in your working directory and add two lines of code:

```fortran
       include 'ttb/ttb_library.f'

       program script101_ttb
       use Tensor
       implicit none

       ! user code

       end program script101_ttb
```
The `include 'ttb/ttb_library.f'` statement replaces the line with the content of the ttb-module. The first line in a program or subroutine is now a `use Tensor` statement. That's it - now you're ready to go.

## Tensor or Voigt Notation

It depends on your preferences: either you store all tensors in full tensor `dimension(3,3)` or in [voigt](https://en.wikipedia.org/wiki/Voigt_notation) `dimension(6)` notation. The equations remain (nearly) the same. Dot Product, Double Dot Product - every function is implemented in both full tensor and voigt notation. Look for the voigt-comments in an [example](https://github.com/adtzlr/ttb/blob/master/hypela2_nh_ttb.f) of a user subroutine for MSC.Marc.

## Access Tensor components by Array

Tensor components may be accessed by a conventional array with the name of the tensor variable `T` followed by a percent operator `%` and a keyword as follows:

- Tensor of rank 1 components as array: `T%a`. i-th component of T: `T%a(i)`
- Tensor of rank 2 components as array: `T%ab`. i,j component of T: `T%ab(i,j)`
- Tensor of rank 4 components as array: `T%abcd`. i,j,k,l component of T: `T%abcd(i,j,k,l)`

- Symmetric Tensor of rank 2 (Voigt) components as array: `T%a6`. i-th component of T: `T%a6(i)`
- Symmetric Tensor of rank 4 (Voigt) components as array: `T%a6b6`. i,j component of T: `T%a6b6(i,j)` (at least minor symmetric)

### Warning: Output as array

It is not possible to access tensor components of a tensor valued function  in a direct way `s = symstore(S1)%a6` - unfortunately this is a limitation of Fortran. To avoid the creation of an extra variable it is possible to use the `asarray(T,i_max[,j_max,k_max,l_max])` function to access tensor components. `i_max,j_max,k_max,l_max` is **not** the single component, instead a slice `T%abcd(1:i_max,1:j_max,1:k_max,1:l_max)` is returned. This can be useful when dealing with mixed formulation or variation principles where the last entry/entries of stress and strain voigt vectors are used for the pressure boundary. To export a full stress tensor `S1` to voigt notation use:

```fortran
       s(1:ndim) = asarray( symstore(S1), ndim )
       d(1:ndim,1:ndim) = asarray( symstore(C4), ndim, ndim )
```

#### Abaqus Users: Output as abqarray

To export a stress tensor to Abaqus Voigt notation use `asabqarray` which reorders the storage indices to `11,22,33,12,13,23`. This function is available for `Tensor2s` and `Tensor4s` data types.

```fortran
       s(1:ndim) = asabqarray( symstore(S1), ndim )
       ddsdde(1:ndim,1:ndim) = asabqarray( symstore(C4), ndim, ndim )
```

## A note on the Permutation of Indices

~Currently only a subset of reordering `(i,j,k,l) --> (i,k,j,l)` with `permute(C4,1,3,2,4)` and `(i,j,k,l) --> (i,l,j,k)` with `permute(C4,1,4,2,3)` is available. Be careful, no error is raised in all other cases. Instead no reordering is perfomed and the input `(i,j,k,l)` ordering will be returned.~
The permutation function reorders indices in the given order for a fourth order tensor of data type `Tensor4`. Example: `(i,j,k,l) --> (i,k,j,l)` with `permute(C4,1,3,2,4)`.

## External Libraries
This library is not using any [LAPACK](http://www.netlib.org/lapack/) functions. Instead you can compile your subroutine with `-o3` flag where at least the Intel compiler translates nested for-loops to [Intel MPI](https://software.intel.com/en-us/intel-mpi-library) functions. I'm open for ideas how to use LAPACK and Intel MPI in the future - please let me know.

## Neo-Hookean Material
With the help of the Tensor module the Second Piola-Kirchhoff stress tensor `S` of a nearly-incompressible Neo-Hookean material model is basically a one-liner:

### Second Piola Kirchhoff Stress Tensor

```fortran
       S = mu*det(C)**(-1./3.)*dev(C)*inv(C)+p*det(C)**(1./2.)*inv(C)
```

While this is of course not the fastest way of calculating the stress tensor it is extremely short and readable. Also the second order tensor variables `S, C` and scalar quantities `mu, p` have to be created at the beginning of the program. A minimal working example for a very simple umat user subroutine can be found in [script_umat.f](https://github.com/adtzlr/ttb/blob/master/script_umat.f). The program is just an example where umat is called and an output information is printed. It is shown that the tensor toolbox is only used inside the material user subroutine umat.

### Material Elasticity Tensor

Isochoric part of the material elasticity tensor `C4_iso` of a nearly-incompressible Neo-Hookean material model:

```fortran
       C4_iso = det(F)**(-2./3.) * 2./3.* (
     *       tr(C) * identity4(inv(C))
     *     - (Eye.dya.inv(C)) - (inv(C).dya.Eye)
     *     + tr(C)/3. * (inv(C).dya.inv(C)) )
```

### Example of MSC.Marc HYPELA2

[Here](https://github.com/adtzlr/ttb/blob/master/hypela2_nh_ttb.f) you can find an example of a nearly-incompressible version of a Neo-Hookean material for MSC.Marc. ~It works **only** in Total Lagrange (no push forward implemented)~. Updated Lagrange is implemented with a push forward of both stress tensor and tangent matrix. Herrmann Elements are automatically detected. As HYPELA2 is called twice per iteration the stiffness calculation is only active during stage `lovl == 4`. One of the best things is the super-simple switch from tensor to voigt notation: Change data types of all symmetric tensors and save the right Cauchy-Green deformation tensor in voigt notation. See commented lines for details.

[Download HYPELA2](https://github.com/adtzlr/ttb/blob/master/hypela2_nh_ttb.f): Neo-Hooke, MSC.Marc, Total Lagrange, Tensor Toolbox

## Sources
Naumann, C.: [Chemisch-mechanisch gekoppelte Modellierung und Simulation oxidativer Alterungsvorgänge in Gummibauteilen (German)](http://nbn-resolving.de/urn:nbn:de:bsz:ch1-qucosa-222075). PhD thesis. Fakultät für Maschinenbau der Technischen Universität Chemnitz, 2016.
