﻿using namespace System.IO;

$moduleRoot = Resolve-Path "$PSScriptRoot/.."
$moduleName = Split-Path $moduleRoot -Leaf

Describe "General project validation: $moduleName" {

  $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse;
  $scripts = $scripts | Where-Object {
    $_.FullName -notMatch $([regex]::Escape([Path]::Join("Tests", "Data", "Modules", "With")))
  }

  # TestCases are splatted to the script so we need hashtables
  $testCase = $scripts | Foreach-Object { @{file = $_ } }
  It "Script <file> should be valid powershell" -TestCases $testCase {
    param($file)

    $file.fullname | Should -Exist

    $contents = Get-Content -Path (Resolve-Path $file.fullname) -ErrorAction Stop
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
    $errors.Count | Should -Be 0
  }
}