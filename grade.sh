CPATH=".;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar"

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

# Clone student repository to student-submission
git clone $1 student-submission
echo 'Finished cloning'

# Check right file submitted
if ! [ -f student-submission/ListExamples.java ]
then
    echo "Missing ListExamples.java in student submission."
    echo "Score: 0"
    exit
fi

# Copy files into grading-area
cp student-submission/*.java grading-area
cp *.java grading-area
cp -r lib grading-area

cd grading-area

# Compile tests and student code
javac -cp $CPATH *.java
if [ $? -ne 0 ]
then
    echo "Compilation Error"
    echo "Score: 0"
    exit
fi

# Run tests and report grade
java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > error-output.txt
head -n 2 error-output.txt | tail -n 1 > test-results.txt
MAX=$(tr -c -d '.' < test-results.txt | wc -c)
ERRORS=$(tr -c -d 'E' < test-results.txt | wc -c)
if [ $ERRORS -ne 0 ]
then
    cat error-output.txt
fi
echo "Score:" $(( $MAX - $ERRORS )) "/" $MAX