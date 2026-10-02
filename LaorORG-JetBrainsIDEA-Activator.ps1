# encoding: utf-8

param(
    [switch]$Offline
)

$script:offline_mode = $Offline -or ($env:JETBRAINS_OFFLINE -eq "1")

Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:OSFamily = if ($env:OS -eq "Windows_NT" -or ($PSVersionTable.PSEdition -eq "Desktop" -and -not $IsMacOS -and -not $IsLinux)) { "Windows" } elseif ($IsMacOS) { "MacOS" } elseif ($IsLinux) { "Linux" } else { "Unknown" }
$script:windows_running = $script:OSFamily -eq "Windows"
$script:mac_running = $script:OSFamily -eq "MacOS"
$script:linux_running = $script:OSFamily -eq "Linux"
$script:enable_debug = $true

try {
    $system_ui_language = (Get-UICulture).Name
    $script:language = "en"
    if ($system_ui_language -like "zh*" -or $system_ui_language -like "zh-*") {
        $script:language = "en"
    }
} catch {
    $script:language = "en"
}

# Internationalization function
function Get-i18nString
{
    param(
        [string]$key
    )

    $i18n = @{
        "processing_env_vars" = @{
            "en" = "Processing {0} environment variables"
        }
        "checking_env" = @{
            "en" = "Checking [{0}]: {1} = '{2}'"
        }
        "deleting_env" = @{
            "en" = "Deleting [{0}]: {1}"
        }
        "welcome_msg" = @{
            "en" = "`nWelcome to JetBrains Activation Tool | LaorORG"
        }
        "script_date" = @{
            "en" = "`nScript Date: 2026-1-28"
        }
        "warning_msg" = @{
            "en" = "`nWarning: This script will forcibly re-activate all products!!!"
        }
        "admin_request" = @{
            "en" = "Administrator privileges will be requested to run, press Enter to continue..."
        }
        "close_products" = @{
            "en" = "`nPlease make sure all JetBrains software is closed, press Enter to continue..."
        }
        "processing" = @{
            "en" = "`nProcessing, please wait patiently..."
        }
        "processing_configs" = @{
            "en" = "`nStarting to process configurations..."
        }
        "not_found_dir" = @{
            "en" = "Directory not found: {0}!"
        }
        "processing_product" = @{
            "en" = "`nProcessing: {0}"
        }
        "not_found_home" = @{
            "en" = ".home file not found: {0}"
        }
        "path_not_exist" = @{
            "en" = "Path does not exist: {0}"
        }
        "not_found_bin" = @{
            "en" = "bin directory not found: {0}"
        }
        "config_exists_cleaning" = @{
            "en" = "{0} configuration file already exists, cleaning..."
        }
        "key_exists_cleaning" = @{
            "en" = "Key already exists, cleaning..."
        }
        "activation_success" = @{
            "en" = "{0} activated successfully!"
        }
        "manual_activation_required" = @{
            "en" = "{0} requires manual activation code entry!"
        }
        "download_failed" = @{
            "en" = "Download failed: {0}"
        }
        "request_failed" = @{
            "en" = "{0} request failed: {1}"
        }
        "file_in_use" = @{
            "en" = "File is in use, please close all JetBrains IDEs and try again!"
        }
        "processing_completed" = @{
            "en" = "`nAll items processed. If you need an activation code, please visit the website!"
        }
        "format_error" = @{
            "en" = "Format error: Please use yyyy-MM-dd format"
        }
        "invalid_date" = @{
            "en" = "Invalid date: {0}"
        }
        "reading_config" = @{
            "en" = "Reading config file: {0}, looking for key: {1}"
        }
        "found_key" = @{
            "en" = "Found key '{0}' with value '{1}'"
        }
        "failed_read_config" = @{
            "en" = "Failed to read config file: {0}"
        }
        "cleaning_vmoptions" = @{
            "en" = "Cleaning VMOptions: {0}"
        }
        "updating_vmoptions" = @{
            "en" = "Updating VMOptions: {0}"
        }
        "processing_disabled_plugins" = @{
            "en" = "Processed file: {0} com.intellij.modules.ultimate item"
        }
        "file_not_exist_skip" = @{
            "en" = "File does not exist, skipping: {0}"
        }
        "error_processing_plugins" = @{
            "en" = "Error processing disabled plugins file: {0}"
        }
        "processing_config" = @{
            "en" = "Processing config: {0}, {1}, {2}"
        }
        "requesting_key" = @{
            "en" = "Requesting key: {0}, request body: {1}, save path: {2}"
        }
        "writing_key" = @{
            "en" = "Writing key, activating: {0}"
        }
        "source_address" = @{
            "en" = "Source ja-netfilter address: https://gitee.com/ja-netfilter/ja-netfilter/releases/tag/2025.3.0"
        }
        "source_privacy" = @{
            "en" = "Source privacy.jar address: https://gitea.998043.xyz/novice/plugin-privacy/releases/tag/release"
        }
        "suggest_check_sha1" = @{
            "en" = "It is recommended to verify the SHA1 value to ensure integrity"
        }
        "configuring_ja_netfilter" = @{
            "en" = "Configuring ja-netfilter:"
        }
        "custom_license_name" = @{
            "en" = "Custom license name (Press Enter to use the default LaorORG)"
        }
        "custom_expiry_date" = @{
            "en" = "Custom expiration date (Press Enter to use the default 2099-12-31)"
        }
        "default_license_name" = @{
            "en" = "LaorORG"
        }
        "default_expiry_date" = @{
            "en" = "2099-12-31"
        }
        "file_path_empty" = @{
            "en" = "File path is empty, skipping processing: {0}"
        }
        "found_home_file" = @{
            "en" = "Found .home file: {0}"
        }
        "read_home_content" = @{
            "en" = "Read .home file content: {0}"
        }
        "found_bin_dir" = @{
            "en" = "Found bin directory: {0}"
        }
        "sha1_info" = @{
            "en" = "{0} :SHA1: {1}"
        }
        "request_fail" = @{
            "en" = "Request failed: {0}"
        }
    }

    if ( $i18n.ContainsKey($key))
    {
        if ( $i18n[$key].ContainsKey($script:language))
        {
            return $i18n[$key][$script:language]
        }
    }

    # Return the key itself if not found
    return $key
}

# Log output function
function Log
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$message,

        [ValidateSet("INFO", "DEBUG", "WARNING", "ERROR", "SUCCESS")]
        [string]$level = "INFO"
    )

    if ($level -eq "DEBUG" -and -not $script:enable_debug)
    {
        return
    }

    switch ($level)
    {
        "INFO" {
            $color = "White"
        }
        "DEBUG" {
            $color = "DarkGray"
        }
        "WARNING" {
            $color = "Yellow"
        }
        "ERROR" {
            $color = "Red"
        }
        "SUCCESS" {
            $color = "Green"
        }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ( $message.StartsWith("`n"))
    {
        $message = $message.Substring(1)
        Write-Host "`n[$timestamp][$level] $message" -ForegroundColor $color
    }
    else
    {
        Write-Host "[$timestamp][$level] $message" -ForegroundColor $color
    }
}

function Debug([string]$message)
{
    $formatArgs = $args
    if ($formatArgs.Count -gt 0)
    {
        try
        {
            $message = $message -f $formatArgs
        }
        catch
        {
            # If formatting fails, keep the original message
        }
    }
    Log -message $message -level "DEBUG"
}
function Warning([string]$message)
{
    $formatArgs = $args
    if ($formatArgs.Count -gt 0)
    {
        try
        {
            $message = $message -f $formatArgs
        }
        catch
        {
            # If formatting fails, keep the original message
        }
    }
    Log -message $message -level "WARNING"
}
function Error([string]$message)
{
    $formatArgs = $args
    if ($formatArgs.Count -gt 0)
    {
        try
        {
            $message = $message -f $formatArgs
        }
        catch
        {
            # If formatting fails, keep the original message
        }
    }
    Log -message $message -level "ERROR"
}
function Success([string]$message)
{
    $formatArgs = $args
    if ($formatArgs.Count -gt 0)
    {
        try
        {
            $message = $message -f $formatArgs
        }
        catch
        {
            # If formatting fails, keep the original message
        }
    }
    Log -message $message -level "SUCCESS"
}

function Pause-ForUser
{
    param(
        [string]$message = "Press Enter to exit..."
    )

    if ($Host.Name -eq "ConsoleHost")
    {
        try
        {
            $null = Read-Host -Prompt $message
        }
        catch
        {
            Start-Sleep -Seconds 2
        }
    }
}

# Exit program
function Exit-Program
{
    Pause-ForUser
    exit 1
}

# Progress bar display
function Write-ProgressCustom([string]$message, [string]$progress_bar, [double]$percent, [string]$color = "White")
{
    $output = "{0} {1} {2}%" -f $message.PadRight(10), $progress_bar,$percent.ToString("F2")
    [Console]::ForegroundColor = $color
    [Console]::Write("`r" + $output.PadRight(100))
    [Console]::ResetColor()
}

function Get-UserHomePath
{
    $user_home = $env:HOME
    if ([string]::IsNullOrWhiteSpace($user_home))
    {
        $user_home = [Environment]::GetFolderPath("UserProfile")
    }

    if ([string]::IsNullOrWhiteSpace($user_home))
    {
        $user_home = [Environment]::GetEnvironmentVariable("USERPROFILE")
    }

    return $user_home
}

function Get-PlatformJetBrainsPaths
{
    $user_home = Get-UserHomePath

    if ($script:windows_running)
    {
        return @{
            Local  = Join-Path -Path $user_home -ChildPath "AppData\Local\JetBrains"
            Roaming = Join-Path -Path $user_home -ChildPath "AppData\Roaming\JetBrains"
            Public = [Environment]::GetEnvironmentVariable("PUBLIC")
        }
    }
    elseif ($script:mac_running)
    {
        return @{
            Local  = Join-Path -Path $user_home -ChildPath "Library/Application Support/JetBrains"
            Roaming = Join-Path -Path $user_home -ChildPath "Library/Application Support/JetBrains"
            Public = "/tmp"
        }
    }
    else
    {
        return @{
            Local  = Join-Path -Path $user_home -ChildPath ".config/JetBrains"
            Roaming = Join-Path -Path $user_home -ChildPath ".config/JetBrains"
            Public = "/tmp"
        }
    }
}

# Create HttpClient instance
function Get-HttP_Client([int]$timeout_seconds = 30)
{
    Add-Type -AssemblyName System.Net.Http
    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.UseDefaultCredentials = $true
    $handler.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()

    $obj_http_client = New-Object System.Net.Http.HttpClient($handler)
    $obj_http_client.Timeout = [System.TimeSpan]::FromSeconds($timeout_seconds)

    # Set User-Agent
    $powershell_ver = $PSVersionTable.PSVersion.ToString()
    if ($script:windows_running)
    {
        $os_label = "Windows NT $([Environment]::OSVersion.Version.ToString())"
    }
    elseif ($script:mac_running)
    {
        $os_label = "Mac OS X $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
    }
    else
    {
        $os_label = "Linux $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
    }

    $ua = "PowerShell/$powershell_ver ($os_label)"
    $obj_http_client.DefaultRequestHeaders.UserAgent.ParseAdd($ua)

    return $obj_http_client
}

# Read date input
function Read-Valid_Date([string]$prompt, [string]$default = "2099-12-31")
{
    $date = ""
    while ([string]::IsNullOrWhiteSpace($date) -or -not ($date -match '^\d{4}-\d{2}-\d{2}$'))
    {
        $date = Read-Host -Prompt $prompt
        if ( [string]::IsNullOrWhiteSpace($date))
        {
            $date = $default
            break
        }

        if (-not ($date -match '^\d{4}-\d{2}-\d{2}$'))
        {
            $msg = Get-i18nString "format_error"
            Write-Host $msg -ForegroundColor Red
            continue
        }

        $date_obj = Get-Date
        if (-not [DateTime]::TryParseExact($date, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$date_obj))
        {
            $msg = Get-i18nString "invalid_date"
            Write-Host ($msg -f $date) -ForegroundColor Red
            $date = ""
        }
    }
    return $date
}

# Display JetBrains ASCII logo
function Show-Ascii_Jetbrains
{
    Write-Host @"
JJJJJJ   EEEEEEE   TTTTTTTT  BBBBBBB    RRRRRR    AAAAAA    IIIIIIII  NNNN   NN   SSSSSS
   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NNNNN  NN  SS
   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN NNN NN   SS
   JJ    EEEEE        TT     BBBBBBB    RRRRRR    AAAAAA       II     NN  NNNNN    SSSSS
   JJ    EE           TT     BB    BB   RR  RR    AA  AA       II     NN   NNNN         SS
JJ JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN    NNN          SS
 JJJJ    EEEEEEE      TT     BBBBBBB    RR   RR   AA  AA    IIIIIIII  NN    NNN    SSSSSS
"@ -ForegroundColor Cyan
}

# Get property value (idea.properties)
function Get_Property_Value([string]$file_path, [string]$key_to_find)
{
    $msg = Get-i18nString "reading_config"
    Debug ($msg -f $file_path, $key_to_find)

    try
    {
        Get-Content -Path $file_path -Encoding UTF8 -ErrorAction Stop | ForEach-Object {
            $line = $_.Trim()
            if (-not $line.StartsWith("#") -and -not [string]::IsNullOrWhiteSpace($line))
            {
                if ($line -match "^\s*([^#=]+?)\s*=\s*(.*)$")
                {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    if ($key -eq $key_to_find)
                    {
                        if ($value -match '\$\{user\.home\}')
                        {
                            $value = $value.Replace('${user.home}', $user_path)
                        }

                        if ($script:windows_running)
                        {
                            $clean_value = [System.IO.Path]::GetFullPath($value.Replace('/', '\').Trim())
                        }
                        else
                        {
                            $clean_value = [System.IO.Path]::GetFullPath($value.Trim())
                        }

                        $msg = Get-i18nString "found_key"
                        Debug ($msg -f $key_to_find, $clean_value)
                        return [string]::new($clean_value)
                    }
                }
            }
        }
    }
    catch
    {
        $msg = Get-i18nString "failed_read_config"
        Debug ($msg -f $_)
    }
}

# Clean environment variables
function Remove_Env([string]$env_scope, [array]$products)
{
    $msg = Get-i18nString "processing_env_vars"
    Log ("`n" + ($msg -f $env_scope))

    foreach ($prd in $products)
    {
        $upper_key2 = "$($prd.name.ToUpper() )_VM_OPTIONS"
        $val_upper2 = [Environment]::GetEnvironmentVariable($upper_key2, $env_scope)
        $msg = Get-i18nString "checking_env"
        Debug $msg $env_scope $upper_key2 $val_upper2

        if (-not [string]::IsNullOrEmpty($val_upper2))
        {
            $msg = Get-i18nString "deleting_env"
            Log ($msg -f $env_scope, $prd.name)
            [Environment]::SetEnvironmentVariable($upper_key2, $null, $env_scope)
        }
    }
}

# Create working directories
function Create_Work_Dir
{
    try
    {
        if (Test-Path -Path $script:dir_work)
        {
            Remove-Item -Path $script:dir_work -Recurse -Force -ErrorAction Stop
        }
        New-Item -Path $script:dir_work -ItemType Directory -Force | Out-Null
        New-Item -Path $script:dir_config -ItemType Directory -Force | Out-Null
        New-Item -Path $script:dir_plugins -ItemType Directory -Force | Out-Null
    }
    catch
    {
        Error (Get-i18nString "file_in_use")
        Exit-Program
    }
}

# Download files
function File_Download
{
    $files = @(
        @{ url = "$script:url_download/ja-netfilter.jar"; save_path = $script:file_netfilter_jar },
        @{ url = "$script:url_download/config/dns.conf"; save_path = [IO.Path]::Combine($script:dir_config, "dns.conf") },
        @{ url = "$script:url_download/config/env.conf"; save_path = [IO.Path]::Combine($script:dir_config, "env.conf") },
        @{ url = "$script:url_download/config/native.conf"; save_path = [IO.Path]::Combine($script:dir_config, "native.conf") },
        @{ url = "$script:url_download/config/power.conf"; save_path = [IO.Path]::Combine($script:dir_config, "power.conf") },
        @{ url = "$script:url_download/config/url.conf"; save_path = [IO.Path]::Combine($script:dir_config, "url.conf") },

        @{ url = "$script:url_download/plugins/dns.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "dns.jar") },
        @{ url = "$script:url_download/plugins/env.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "env.jar") },
        @{ url = "$script:url_download/plugins/native.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "native.jar") },
        @{ url = "$script:url_download/plugins/power.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "power.jar") },
        @{ url = "$script:url_download/plugins/url.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "url.jar") },
        @{ url = "$script:url_download/plugins/hideme.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "hideme.jar") },
        @{ url = "$script:url_download/plugins/privacy.jar"; save_path = [IO.Path]::Combine($script:dir_plugins, "privacy.jar") }
    )

    if ($script:offline_mode)
    {
        Warning "Offline mode enabled; skipping remote downloads and using local files only."
        foreach ($file in $files)
        {
            $dir = Split-Path -Path $file.save_path -Parent
            if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -Path $dir))
            {
                New-Item -Path $dir -ItemType Directory -Force | Out-Null
            }

            if (Test-Path -Path $file.save_path)
            {
                Debug ("Using existing offline file: {0}" -f $file.save_path)
                continue
            }

            if ($file.url.EndsWith(".jar"))
            {
                Warning ("Offline jar missing; create it manually before activation: {0}" -f $file.save_path)
            }
            else
            {
                Set-Content -Path $file.save_path -Value "# Offline placeholder generated for local use" -Force
            }
        }
        return
    }

    $obj_http_client = Get-HttP_Client
    $total_files = $files.Count
    $current_file = 0

    Debug (Get-i18nString "source_address")
    Debug (Get-i18nString "source_privacy")
    Debug (Get-i18nString "suggest_check_sha1")

    foreach ($file in $files)
    {
        $current_file++
        $percent = [math]::Round(($current_file / $total_files) * 100, 2)
        $bar_length = 30
        $filled_bars = [math]::Floor($percent / (100 / $bar_length))
        $progress_bar = "[" + ("#" * $filled_bars) + ("." * ($bar_length - $filled_bars)) + "]"

        Write-ProgressCustom -message (Get-i18nString "configuring_ja_netfilter") -progress_bar $progress_bar -percent $percent -color Green

        try
        {
            $response = $obj_http_client.GetAsync($file.url).Result
            $response.EnsureSuccessStatusCode() | Out-Null
            $content = $response.Content.ReadAsByteArrayAsync().Result
            [System.IO.File]::WriteAllBytes($file.save_path, $content)

            if ( $file.url.Contains(".jar"))
            {
                $sha1 = [BitConverter]::ToString([Security.Cryptography.SHA1]::Create().ComputeHash($content))
                $msg = Get-i18nString "sha1_info"
                Debug ($msg -f $file.url, $sha1)
            }
        }
        catch
        {
            $msg = Get-i18nString "download_failed"
            Error ($msg -f $file.url)
            $msg = Get-i18nString "request_fail"
            Debug ($msg -f $_.Exception.Message)
            $obj_http_client.CancelPendingRequests()
            Exit-Program
        }
    }

    $obj_http_client.Dispose()
}

# Clean vmoptions files
function Revert_Vm_Options([string]$file_path)
{
    $lines = Get-Content -Path $file_path -Encoding UTF8 -ErrorAction SilentlyContinue
    $filtered_lines = $lines | Where-Object {
        -not $script:regex.IsMatch($_)
    }
    Set-Content -Path $file_path -Value $filtered_lines -Force
    $msg = Get-i18nString "cleaning_vmoptions"
    Debug ($msg -f $file_path)
}

# Append config to vmoptions file
function Append_Vm_Options([string]$file_path)
{
    if (Test-Path -Path $file_path)
    {
        Add-Content -Path $file_path -Value $script:content -Force
        $msg = Get-i18nString "updating_vmoptions"
        Debug ($msg -f $file_path)
    }
}

# Read file and clear the line containing com.intellij.modules.ultimate if present
function Process_Disabled_Plugins([string]$file_disabled_plugins)
{
    # Validate parameters
    if ( [string]::IsNullOrWhiteSpace($file_disabled_plugins))
    {
        $msg = Get-i18nString "file_path_empty"
        Debug ($msg -f $file_disabled_plugins)
        return
    }

    # Check whether the file exists
    if (-not (Test-Path -Path $file_disabled_plugins))
    {
        $msg = Get-i18nString "file_not_exist_skip"
        Debug ($msg -f $file_disabled_plugins)
        return
    }

    try
    {
        # Read file content
        $content = Get-Content -Path $file_disabled_plugins -Encoding UTF8 -ErrorAction Stop

        # Remove lines containing com.intellij.modules.ultimate
        $filtered_content = $content | Where-Object { $_ -ne "com.intellij.modules.ultimate" }

        # Write the file back if filtering changed it
        if ($content.Count -ne $filtered_content.Count)
        {
            Set-Content -Path $file_disabled_plugins -Value $filtered_content -Encoding UTF8 -Force
            $msg = Get-i18nString "processing_disabled_plugins"
            Debug ($msg -f $file_disabled_plugins)
        }
    }
    catch
    {
        $msg = Get-i18nString "error_processing_plugins"
        Warning ($msg -f $_)
    }
}

# Create activation key
function Create_Key([hashtable]$product, [string]$prd_full_name, [string]$custom_config_path)
{
    $msg = Get-i18nString "processing_config"
    Debug ($msg -f $product.name, $prd_full_name, $custom_config_path)

    if (![string]::IsNullOrWhiteSpace($custom_config_path))
    {
        $dir_product = $custom_config_path
    }
    else
    {
        $dir_product = Join-Path -Path $script:dir_roaming_jetbrains -ChildPath $prd_full_name
    }

    if (-not (Test-Path -Path $dir_product))
    {
        $msg = Get-i18nString "manual_activation_required"
        Warning ($msg -f $prd_full_name)
        return
    }

    $vm_option_candidates = @(
        (Join-Path -Path $dir_product "$($product.name)64.exe.vmoptions"),
        (Join-Path -Path $dir_product "$($product.name)64.vmoptions"),
        (Join-Path -Path $dir_product "$($product.name).exe.vmoptions"),
        (Join-Path -Path $dir_product "$($product.name).vmoptions")
    )
    $file_vm_options = $vm_option_candidates | Where-Object { Test-Path -Path $_ } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($file_vm_options))
    {
        $file_vm_options = $vm_option_candidates[0]
    }

    $file_key = Join-Path -Path $dir_product "$($product.name).key"
    $file_disable_plugins = Join-Path -Path $dir_product "disabled_plugins.txt"

    if (Test-Path -Path $file_vm_options)
    {
        $msg = Get-i18nString "config_exists_cleaning"
        Debug ($msg -f $prd_full_name)
        Revert_Vm_Options -file_path $file_vm_options
    }

    if (Test-Path -Path $file_key)
    {
        $msg = Get-i18nString "key_exists_cleaning"
        Debug ($msg)
        Remove-Item -Path $file_key -Force
    }

    $json_body = ConvertTo-Json -InputObject @{
        assigneeName = $script:license.assigneeName
        expiryDate = $script:license.expiryDate
        licenseName = $script:license.licenseName
        productCode = $product.product_code
    }
    $msg = Get-i18nString "requesting_key"
    Debug ($msg -f $script:url_license, $json_body, $file_key)
    $obj_http_client = Get-HttP_Client
    try
    {
        $response = $obj_http_client.PostAsync(
                $script:url_license,
                [System.Net.Http.StringContent]::new($json_body, [System.Text.Encoding]::UTF8, "application/json")
        ).Result

        $response.EnsureSuccessStatusCode() | Out-Null
        $key_bytes = $response.Content.ReadAsByteArrayAsync().Result
        $msg = Get-i18nString "writing_key"
        Debug ($msg -f $file_key)
        [System.IO.File]::WriteAllBytes($file_key, $key_bytes)
        Process_Disabled_Plugins($file_disable_plugins)
        $msg = Get-i18nString "activation_success"
        Success ($msg -f $prd_full_name)
    }
    catch
    {
        $msg = Get-i18nString "manual_activation_required"
        Warning ($msg -f $prd_full_name)
        $msg = Get-i18nString "request_failed"
        Debug ($msg -f $prd_full_name, $_.Exception.Message)
    }
    finally
    {
        $obj_http_client.Dispose()
    }
}

# Process all JetBrains products
function Process_Vm_Options
{
    Log (Get-i18nString "processing_configs")

    # Check whether $script:dir_local_jetbrains exists
    if (!(Test-Path -Path $script:dir_local_jetbrains))
    {
        $msg = Get-i18nString "not_found_dir"
        Error ($msg -f $script:dir_local_jetbrains)
        Exit-Program
    }
    $dirs_local_prds = Get-ChildItem -Path $script:dir_local_jetbrains -Directory

    foreach ($dir_prd in $dirs_local_prds)
    {
        $prd = Is_Product -prd_dir_name $dir_prd.Name
        if ($null -eq $prd)
        {
            continue
        }

        $msg = Get-i18nString "processing_product"
        Log ($msg -f $dir_prd)

        $file_home = Join-Path -Path $dir_prd.FullName ".home"
        if (-not (Test-Path -Path $file_home))
        {
            $msg = Get-i18nString "not_found_home"
            Warning ($msg -f $file_home)
            continue
        }
        $msg = Get-i18nString "found_home_file"
        Debug ($msg -f $file_home)
        $content_home = Get-Content -Path $file_home -Encoding UTF8
        if (-not (Test-Path -Path $content_home))
        {
            $msg = Get-i18nString "path_not_exist"
            Warning ($msg -f $content_home)
            continue
        }
        $msg = Get-i18nString "read_home_content"
        Debug ($msg -f $content_home)
        $dir_real_product = Join-Path -Path $content_home "bin"
        if (-not (Test-Path -Path $dir_real_product))
        {
            $msg = Get-i18nString "not_found_bin"
            Warning ($msg -f $dir_real_product)
            continue
        }
        $msg = Get-i18nString "found_bin_dir"
        Debug ($msg -f $dir_real_product)
        $files_vm_options = Get-ChildItem -Path $dir_real_product -Filter "*.vmoptions" -Recurse
        foreach ($file_vm_options in $files_vm_options)
        {
            Revert_Vm_Options -file_path $file_vm_options.FullName
            Append_Vm_Options -file_path $file_vm_options.FullName
        }

        $file_properties = Join-Path -Path $dir_real_product "idea.properties"
        $custom_config_path = Get_Property_Value -file_path $file_properties -key_to_find "idea.config.path"
        Create_Key -product $prd -prd_full_name $dir_prd.Name -custom_config_path $custom_config_path
    }
}

# Check whether it is a JetBrains product
function Is_Product([string]$prd_dir_name)
{
    foreach ($prd in $script:sPrds)
    {
        if ( $prd_dir_name.ToLower().Contains($prd.name))
        {
            return $prd
        }
    }
    return $null
}

# Get user license information
function Read_Host_License_Info
{
    $new_license_name = Read-Host -Prompt (Get-i18nString "custom_license_name")
    if ( [string]::IsNullOrEmpty($new_license_name))
    {
        $new_license_name = Get-i18nString "default_license_name"
    }
    $script:license.licenseName = $new_license_name

    $new_expiry = Read-Valid_Date -prompt (Get-i18nString "custom_expiry_date")
    if ( [string]::IsNullOrEmpty($new_expiry))
    {
        $new_expiry = Get-i18nString "default_expiry_date"
    }
    $script:license.expiryDate = $new_expiry
}

# Main program entry
function Main
{
    Show-Ascii_Jetbrains
    Log (Get-i18nString "welcome_msg")
    Warning (Get-i18nString "script_date")
    Error (Get-i18nString "warning_msg")

    # Elevation check
    if ($script:windows_running)
    {
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
        {
            Warning (Get-i18nString "admin_request")
            Pause-ForUser
            Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Offline') | Out-Null
            exit -1
        }
    }
    else
    {
        Warning "Non-Windows host detected; continuing without elevated permissions."
    }

    Warning (Get-i18nString "close_products")
    Pause-ForUser

    # Initialize global variables
    $user_path = Get-UserHomePath
    $platform_paths = Get-PlatformJetBrainsPaths
    $public_path = if ([string]::IsNullOrWhiteSpace($platform_paths.Public)) { "/tmp" } else { $platform_paths.Public }
    #$script:url_base = "http://127.0.0.1:10768"
    $script:url_base = "https://ckey.run"
    $script:url_download = "$script:url_base/ja-netfilter"
    $script:url_license = "$script:url_base/generateLicense/file"

    $script:dir_work = Join-Path -Path $public_path -ChildPath ".jb_run"
    $script:dir_config = Join-Path -Path $script:dir_work -ChildPath "config"
    $script:dir_plugins = Join-Path -Path $script:dir_work -ChildPath "plugins"
    $script:file_netfilter_jar = Join-Path -Path $script:dir_work "ja-netfilter.jar"
    $script:dir_local_jetbrains = $platform_paths.Local
    $script:dir_roaming_jetbrains = $platform_paths.Roaming

    # Regular expressions
    $pattern = '^-javaagent:.*[/\\]*\.jar.*'
    $script:regex = New-Object System.Text.RegularExpressions.Regex $pattern, ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)

    # Configuration content
    $script:content = @(
        "-javaagent:$($script:file_netfilter_jar.Replace("\", "/") )"
    )

    # Product list
    $script:sPrds = @(
        @{ name = "idea";     product_code = "II,PCWMP,PSI" }
        @{ name = "clion"; product_code = "CL,PSI,PCWMP" }
        @{ name = "phpstorm"; product_code = "PS,PCWMP,PSI" }
        @{ name = "goland"; product_code = "GO,PSI,PCWMP" }
        @{ name = "pycharm"; product_code = "PC,PSI,PCWMP" }
        @{ name = "webstorm"; product_code = "WS,PCWMP,PSI" }
        @{ name = "rider"; product_code = "RD,PDB,PSI,PCWMP" }
        @{ name = "datagrip"; product_code = "DB,PSI,PDB" }
        @{ name = "rubymine"; product_code = "RM,PCWMP,PSI" }
        @{ name = "appcode"; product_code = "AC,PCWMP,PSI" }
        @{ name = "dataspell"; product_code = "DS,PSI,PDB,PCWMP" }
        @{ name = "rustrover"; product_code = "RR,PSI,PCWP" }
    )

    # License information
    $script:license = [PSCustomObject]@{
        assigneeName = ""
        expiryDate = "2099-12-31"
        licenseName = "LaorORG"
        productCode = ""
    }

    # Start main workflow
    Read_Host_License_Info
    Log (Get-i18nString "processing")

    Remove_Env -env_scope "User" -products $script:sPrds
    Remove_Env -env_scope "Machine" -products $script:sPrds

    Create_Work_Dir
    File_Download
    Process_Vm_Options

    Log (Get-i18nString "processing_completed")
    Start-Sleep -Seconds 2
    Pause-ForUser
}

Main
