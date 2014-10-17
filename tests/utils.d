module tests.utils;

bool instanceof(A, B)(B value) {
   return cast(A)value ? true : false;
}

