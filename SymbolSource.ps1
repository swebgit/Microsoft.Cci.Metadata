
$version = 1.0.64355.0

function Search-And-Replace ($path, $lookup) {
    Write-Output ("Replacing in {0}" -f $path)
    Get-ChildItem -Path $path -Recurse -Exclude .git -Include *.cs | ForEach-Object { 
        Write-Verbose "`t$_";
        (Get-Content $_) | ForEach-Object {
            Write-Debug "`t`t`t$_"
            $line = $_
            $lookup.GetEnumerator() | ForEach-Object {
                Write-Debug ("`t`t`t`tReplacing {0} with {1} in {2}" -f $_.Key, $_.Value, $line)
                $line = $line -replace $_.Key, $_.Value
            }
            $line
        } | Set-Content $_ 
    }
    Write-Output "Done"
}

exit
Search-And-Replace . @{
    '^  ((private|internal|protected) )*(internal )*(((sealed|partial|abstract|partial) )*)(class|interface|enum) $' = '  public $4$7 '
}

msbuild Build\ccimetadata.build /p:CCNetLabel=$version
.\NuGet pack SymbolSource.nuspec -version $version -symbols

exit
(
    "  protected internal sealed partial class ",
    "  internal abstract partial class ",
    "  class "
) | ForEach-Object {
    $_ -replace '^  ((private|internal|protected) )*(internal )*(((sealed|partial|abstract|partial) )*)(class|interface|enum) $', '  public $4$7 ' }
