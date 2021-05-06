int sum(int* arr, int len) {
    int sum = 0;
    int* p;
    for (p = arr; p < arr + len; p++) 
        sum += (*p);
    return sum;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    int ans = sum(arr, 5);
    return 0;
}