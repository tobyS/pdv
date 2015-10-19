<?php

interface SimplestInterface {
}

interface DerivedInterface extends BaseInterface
{
}

interface DoublyDerivedInterface extends BaseInterface1, BaseInterface2
{
}

	interface IndentedInterface {
	}

  interface SpaceIndentedInterface {
  }

  interface     SpacedInterface		extends    BaseInterface1   , 	BaseInterface2
  {
  }
