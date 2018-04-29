# Fibonacci numbers;
begin
int n = 0;
int i = 3;
int a = 0;
int b = 1;
int c;
print 'enter a number';
n = read;
print 'fibonacci series :';
if (n == 0)
{
print n;
};
else
{
print a;
print b;
};
while (i <= n)
{
c = a + b;
a = b;
b = c;
i = i + 1;
print b;
};
end
