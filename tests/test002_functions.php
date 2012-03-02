<?php

abstract class TestClass
{

    public function simplesFunc () {
    }

    public function whiteSpaceNoParamsFunc(  )
    {
    }

public function simpleParamFunc( $parameter )
{
}

    public function paramFuncIntDefault( $parameter = 23 ) {
    }

  public function multiParamsFuncFloatDefault( $someParam = 42.5, $anotherParam )
  {
  }

public function typeHintParamsFunc(array $foo, SomeClass $bar) {
}

    public function complexDefaultFunc( array $foo = array( 1, 2, 3 ) ) {
    }

    public function multiLineParamListFunc(
        FirstParam $firstParam = null,
        SecondParam $secondParam,
        $thirdParam = array( "foo", array( "bar" ) ),
        $fourthParam = 42.23
    ) {
    }

    protected function protectedFunc( $foo = null, array $bar )
    {
    }

    private static function privateStaticFunc( SomeClass $foo = null )
    {
    }

    abstract public function abstractPublicFunc();

    protected abstract function protectedAbstractFunc($foo="bar");

}
